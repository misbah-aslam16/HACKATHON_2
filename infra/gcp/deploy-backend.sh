#!/bin/bash

# Deploy Backend to Google Cloud Run

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load configuration
if [ ! -f .env.gcp ]; then
    echo -e "${RED}Error: .env.gcp not found. Run setup-gcp.sh first${NC}"
    exit 1
fi

source .env.gcp

echo -e "${YELLOW}=== Deploying Backend to Cloud Run ===${NC}"
echo "Project: $GCP_PROJECT_ID"
echo "Region: $GCP_REGION"
echo "Service: $BACKEND_SERVICE_NAME"

# Check if Docker image exists locally
IMAGE_NAME="$ARTIFACT_REGISTRY_URL/backend:latest"

echo -e "${YELLOW}Building Docker image...${NC}"
docker build -f infra/docker/Dockerfile.backend \
    -t $IMAGE_NAME \
    -t $ARTIFACT_REGISTRY_URL/backend:$(date +%Y%m%d-%H%M%S) \
    .

if [ $? -ne 0 ]; then
    echo -e "${RED}Docker build failed${NC}"
    exit 1
fi

echo -e "${GREEN}Docker image built successfully${NC}"

# Push to Artifact Registry
echo -e "${YELLOW}Pushing image to Artifact Registry...${NC}"
docker push $IMAGE_NAME

if [ $? -ne 0 ]; then
    echo -e "${RED}Docker push failed${NC}"
    exit 1
fi

echo -e "${GREEN}Image pushed successfully${NC}"

# Get database credentials from environment or .env files
if [ -z "$DATABASE_URL" ]; then
    echo -e "${YELLOW}Reading DATABASE_URL from backend/.env...${NC}"
    if [ -f backend/.env ]; then
        DATABASE_URL=$(grep "^DATABASE_URL=" backend/.env | cut -d '=' -f 2-)
        DATABASE_URL_UNPOOLED=$(grep "^DATABASE_URL_UNPOOLED=" backend/.env | cut -d '=' -f 2-)
    else
        echo -e "${RED}Error: DATABASE_URL not set and backend/.env not found${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Deploying to Cloud Run...${NC}"

gcloud run deploy $BACKEND_SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $GCP_REGION \
    --memory $BACKEND_MEMORY \
    --cpu $BACKEND_CPU \
    --timeout 3600 \
    --max-instances $MAX_INSTANCES \
    --allow-unauthenticated \
    --set-env-vars \
        DATABASE_URL="$DATABASE_URL",\
        DATABASE_URL_UNPOOLED="$DATABASE_URL_UNPOOLED",\
        PORT=8080 \
    --quiet

if [ $? -ne 0 ]; then
    echo -e "${RED}Cloud Run deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}Backend deployed successfully!${NC}"

# Get service URL
BACKEND_URL=$(gcloud run services describe $BACKEND_SERVICE_NAME \
    --region $GCP_REGION \
    --format 'value(status.url)')

echo -e "${GREEN}Backend URL: $BACKEND_URL${NC}"
echo ""
echo -e "${YELLOW}Next: Deploy frontend with:${NC}"
echo "export BACKEND_URL=$BACKEND_URL"
echo "./deploy-frontend.sh"
