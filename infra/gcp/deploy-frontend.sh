#!/bin/bash

# Deploy Frontend to Google Cloud Run

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

echo -e "${YELLOW}=== Deploying Frontend to Cloud Run ===${NC}"
echo "Project: $GCP_PROJECT_ID"
echo "Region: $GCP_REGION"
echo "Service: $FRONTEND_SERVICE_NAME"

# Get backend URL
if [ -z "$BACKEND_URL" ]; then
    echo -e "${YELLOW}Retrieving backend URL...${NC}"
    BACKEND_URL=$(gcloud run services describe $BACKEND_SERVICE_NAME \
        --region $GCP_REGION \
        --format 'value(status.url)' 2>/dev/null || echo "")
    
    if [ -z "$BACKEND_URL" ]; then
        echo -e "${RED}Error: Could not retrieve backend URL. Deploy backend first.${NC}"
        exit 1
    fi
fi

echo "Backend URL: $BACKEND_URL"

# Check if Docker image exists locally
IMAGE_NAME="$ARTIFACT_REGISTRY_URL/frontend:latest"

echo -e "${YELLOW}Building Docker image...${NC}"
docker build -f infra/docker/Dockerfile.frontend \
    --build-arg NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL \
    --build-arg NEXT_PUBLIC_APP_URL=https://$FRONTEND_SERVICE_NAME-xxxxx.run.app \
    -t $IMAGE_NAME \
    -t $ARTIFACT_REGISTRY_URL/frontend:$(date +%Y%m%d-%H%M%S) \
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

# Get database and auth credentials
if [ -z "$DATABASE_URL" ]; then
    echo -e "${YELLOW}Reading credentials from todo-app-fullstack/.env...${NC}"
    if [ -f todo-app-fullstack/.env ]; then
        DATABASE_URL=$(grep "^DATABASE_URL=" todo-app-fullstack/.env | cut -d '=' -f 2-)
        DATABASE_URL_UNPOOLED=$(grep "^DATABASE_URL_UNPOOLED=" todo-app-fullstack/.env | cut -d '=' -f 2-)
        AUTH_SECRET=$(grep "^AUTH_SECRET=" todo-app-fullstack/.env | cut -d '=' -f 2-)
        BETTER_AUTH_SECRET=$(grep "^BETTER_AUTH_SECRET=" todo-app-fullstack/.env | cut -d '=' -f 2-)
    else
        echo -e "${RED}Error: DATABASE_URL not set and todo-app-fullstack/.env not found${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Deploying to Cloud Run...${NC}"

gcloud run deploy $FRONTEND_SERVICE_NAME \
    --image $IMAGE_NAME \
    --platform managed \
    --region $GCP_REGION \
    --memory $FRONTEND_MEMORY \
    --cpu $FRONTEND_CPU \
    --timeout 3600 \
    --max-instances $MAX_INSTANCES \
    --allow-unauthenticated \
    --set-env-vars \
        NEXT_PUBLIC_BACKEND_URL="$BACKEND_URL",\
        DATABASE_URL="$DATABASE_URL",\
        DATABASE_URL_UNPOOLED="$DATABASE_URL_UNPOOLED",\
        AUTH_SECRET="$AUTH_SECRET",\
        BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET",\
        PORT=3000 \
    --quiet

if [ $? -ne 0 ]; then
    echo -e "${RED}Cloud Run deployment failed${NC}"
    exit 1
fi

echo -e "${GREEN}Frontend deployed successfully!${NC}"

# Get service URL
FRONTEND_URL=$(gcloud run services describe $FRONTEND_SERVICE_NAME \
    --region $GCP_REGION \
    --format 'value(status.url)')

echo -e "${GREEN}Frontend URL: $FRONTEND_URL${NC}"
echo ""
echo -e "${YELLOW}=== Deployment Complete ===${NC}"
echo "Backend: $BACKEND_URL"
echo "Frontend: $FRONTEND_URL"
