#!/bin/bash

# Google Cloud Run Setup Script
# This script initializes GCP resources for Todo App deployment

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Google Cloud Run Setup ===${NC}"

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get project ID
read -p "Enter your GCP Project ID: " GCP_PROJECT_ID
read -p "Enter GCP Region (default: us-central1): " GCP_REGION
GCP_REGION=${GCP_REGION:-us-central1}

read -p "Enter Artifact Registry Repository name (default: todo-app): " ARTIFACT_REGISTRY_REPO
ARTIFACT_REGISTRY_REPO=${ARTIFACT_REGISTRY_REPO:-todo-app}

ARTIFACT_REGISTRY_REGION=$GCP_REGION

echo -e "${YELLOW}Configuration:${NC}"
echo "Project ID: $GCP_PROJECT_ID"
echo "Region: $GCP_REGION"
echo "Artifact Registry: $ARTIFACT_REGISTRY_REPO"

# Set project
echo -e "${YELLOW}Setting GCP project...${NC}"
gcloud config set project $GCP_PROJECT_ID

# Authenticate
echo -e "${YELLOW}Authenticating with GCP...${NC}"
gcloud auth login

# Enable required APIs
echo -e "${YELLOW}Enabling required APIs...${NC}"
gcloud services enable \
    run.googleapis.com \
    artifactregistry.googleapis.com \
    cloudbuild.googleapis.com \
    containerregistry.googleapis.com

# Create Artifact Registry repository
echo -e "${YELLOW}Creating Artifact Registry repository...${NC}"
if gcloud artifacts repositories describe $ARTIFACT_REGISTRY_REPO \
    --location=$ARTIFACT_REGISTRY_REGION &> /dev/null; then
    echo -e "${GREEN}Repository already exists${NC}"
else
    gcloud artifacts repositories create $ARTIFACT_REGISTRY_REPO \
        --repository-format=docker \
        --location=$ARTIFACT_REGISTRY_REGION \
        --description="Todo App Docker Images"
    echo -e "${GREEN}Repository created${NC}"
fi

# Configure Docker authentication
echo -e "${YELLOW}Configuring Docker authentication...${NC}"
gcloud auth configure-docker $ARTIFACT_REGISTRY_REGION-docker.pkg.dev

# Create .env.gcp file with configuration
echo -e "${YELLOW}Creating .env.gcp configuration file...${NC}"
cat > .env.gcp << EOF
# GCP Configuration
GCP_PROJECT_ID=$GCP_PROJECT_ID
GCP_REGION=$GCP_REGION
ARTIFACT_REGISTRY_REPO=$ARTIFACT_REGISTRY_REPO
ARTIFACT_REGISTRY_REGION=$ARTIFACT_REGISTRY_REGION
ARTIFACT_REGISTRY_URL=$ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO

# Service Names
BACKEND_SERVICE_NAME=todo-backend
FRONTEND_SERVICE_NAME=todo-frontend

# Resource Configuration
BACKEND_MEMORY=512Mi
BACKEND_CPU=1
FRONTEND_MEMORY=512Mi
FRONTEND_CPU=1
MAX_INSTANCES=10
EOF

echo -e "${GREEN}Configuration saved to .env.gcp${NC}"

# Display next steps
echo -e "${YELLOW}=== Setup Complete ===${NC}"
echo -e "${GREEN}Next steps:${NC}"
echo "1. Update .env.gcp with your database credentials"
echo "2. Run: source .env.gcp"
echo "3. Run: ./deploy-all.sh"
echo ""
echo -e "${YELLOW}Or deploy manually:${NC}"
echo "source .env.gcp"
echo "./deploy-backend.sh"
echo "./deploy-frontend.sh"
