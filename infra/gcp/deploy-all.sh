#!/bin/bash

# Deploy Both Backend and Frontend to Google Cloud Run

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}=== Todo App - Complete Cloud Run Deployment ===${NC}"

# Check if .env.gcp exists
if [ ! -f .env.gcp ]; then
    echo -e "${RED}Error: .env.gcp not found${NC}"
    echo "Run setup-gcp.sh first to initialize GCP resources"
    exit 1
fi

# Make scripts executable
chmod +x deploy-backend.sh deploy-frontend.sh

# Deploy backend
echo -e "${YELLOW}Step 1: Deploying Backend...${NC}"
./deploy-backend.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}Backend deployment failed${NC}"
    exit 1
fi

# Get backend URL for frontend deployment
source .env.gcp
BACKEND_URL=$(gcloud run services describe $BACKEND_SERVICE_NAME \
    --region $GCP_REGION \
    --format 'value(status.url)')

# Deploy frontend
echo -e "${YELLOW}Step 2: Deploying Frontend...${NC}"
export BACKEND_URL=$BACKEND_URL
./deploy-frontend.sh

if [ $? -ne 0 ]; then
    echo -e "${RED}Frontend deployment failed${NC}"
    exit 1
fi

# Get URLs
FRONTEND_URL=$(gcloud run services describe $FRONTEND_SERVICE_NAME \
    --region $GCP_REGION \
    --format 'value(status.url)')

echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo ""
echo -e "${GREEN}Services deployed successfully!${NC}"
echo ""
echo "Backend Service:"
echo "  Name: $BACKEND_SERVICE_NAME"
echo "  URL: $BACKEND_URL"
echo "  Region: $GCP_REGION"
echo ""
echo "Frontend Service:"
echo "  Name: $FRONTEND_SERVICE_NAME"
echo "  URL: $FRONTEND_URL"
echo "  Region: $GCP_REGION"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo ""
echo "View logs:"
echo "  gcloud run logs read $BACKEND_SERVICE_NAME --region $GCP_REGION --limit 50"
echo "  gcloud run logs read $FRONTEND_SERVICE_NAME --region $GCP_REGION --limit 50"
echo ""
echo "View service details:"
echo "  gcloud run services describe $BACKEND_SERVICE_NAME --region $GCP_REGION"
echo "  gcloud run services describe $FRONTEND_SERVICE_NAME --region $GCP_REGION"
echo ""
echo "Update environment variables:"
echo "  gcloud run services update $BACKEND_SERVICE_NAME --region $GCP_REGION --update-env-vars KEY=VALUE"
echo "  gcloud run services update $FRONTEND_SERVICE_NAME --region $GCP_REGION --update-env-vars KEY=VALUE"
echo ""
echo "Delete services:"
echo "  gcloud run services delete $BACKEND_SERVICE_NAME --region $GCP_REGION"
echo "  gcloud run services delete $FRONTEND_SERVICE_NAME --region $GCP_REGION"
