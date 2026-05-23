#!/bin/bash

# ⚡ IMMEDIATE DEPLOYMENT SCRIPT
# Run this to deploy your application to Cloud Run NOW

set -e

# Configuration
GCP_PROJECT_ID="todo-497210"
GCP_REGION="us-central1"
ARTIFACT_REGISTRY_REPO="todo-app"
ARTIFACT_REGISTRY_REGION="us-central1"
BACKEND_SERVICE_NAME="todo-backend"
FRONTEND_SERVICE_NAME="todo-frontend"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║         🚀 DEPLOYING TODO APP TO CLOUD RUN                    ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Step 1: Authenticate
echo -e "${YELLOW}Step 1: Authenticating with Google Cloud...${NC}"
gcloud auth login
gcloud config set project $GCP_PROJECT_ID
echo -e "${GREEN}✅ Authenticated${NC}"
echo ""

# Step 2: Enable APIs
echo -e "${YELLOW}Step 2: Enabling required APIs...${NC}"
gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com
echo -e "${GREEN}✅ APIs enabled${NC}"
echo ""

# Step 3: Create Artifact Registry
echo -e "${YELLOW}Step 3: Creating Artifact Registry repository...${NC}"
gcloud artifacts repositories create $ARTIFACT_REGISTRY_REPO \
  --repository-format=docker \
  --location=$ARTIFACT_REGISTRY_REGION \
  --description="Todo App Docker Images" 2>/dev/null || echo "Repository already exists"
echo -e "${GREEN}✅ Artifact Registry ready${NC}"
echo ""

# Step 4: Configure Docker
echo -e "${YELLOW}Step 4: Configuring Docker authentication...${NC}"
gcloud auth configure-docker $ARTIFACT_REGISTRY_REGION-docker.pkg.dev
echo -e "${GREEN}✅ Docker configured${NC}"
echo ""

# Step 5: Build and push backend
echo -e "${YELLOW}Step 5: Building and pushing backend image...${NC}"
BACKEND_IMAGE="${ARTIFACT_REGISTRY_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/backend:latest"
docker build -f infra/docker/Dockerfile.backend \
  -t $BACKEND_IMAGE .
docker push $BACKEND_IMAGE
echo -e "${GREEN}✅ Backend image pushed${NC}"
echo ""

# Step 6: Build and push frontend
echo -e "${YELLOW}Step 6: Building and pushing frontend image...${NC}"
FRONTEND_IMAGE="${ARTIFACT_REGISTRY_REGION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/frontend:latest"
docker build -f infra/docker/Dockerfile.frontend \
  -t $FRONTEND_IMAGE .
docker push $FRONTEND_IMAGE
echo -e "${GREEN}✅ Frontend image pushed${NC}"
echo ""

# Step 7: Deploy backend
echo -e "${YELLOW}Step 7: Deploying backend to Cloud Run...${NC}"
gcloud run deploy $BACKEND_SERVICE_NAME \
  --image $BACKEND_IMAGE \
  --platform managed \
  --region $GCP_REGION \
  --memory 512Mi \
  --cpu 1 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require",DATABASE_URL_UNPOOLED="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require",PORT=8080 \
  --quiet
echo -e "${GREEN}✅ Backend deployed${NC}"
echo ""

# Step 8: Get backend URL
echo -e "${YELLOW}Step 8: Getting backend URL...${NC}"
BACKEND_URL=$(gcloud run services describe $BACKEND_SERVICE_NAME \
  --region $GCP_REGION \
  --format 'value(status.url)')
echo -e "${GREEN}✅ Backend URL: $BACKEND_URL${NC}"
echo ""

# Step 9: Deploy frontend
echo -e "${YELLOW}Step 9: Deploying frontend to Cloud Run...${NC}"
gcloud run deploy $FRONTEND_SERVICE_NAME \
  --image $FRONTEND_IMAGE \
  --platform managed \
  --region $GCP_REGION \
  --memory 512Mi \
  --cpu 1 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated \
  --set-env-vars NEXT_PUBLIC_BACKEND_URL="$BACKEND_URL",DATABASE_URL="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require",DATABASE_URL_UNPOOLED="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require",AUTH_SECRET="dev-better-auth-secret-change-in-production",BETTER_AUTH_SECRET="wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=",PORT=3000 \
  --quiet
echo -e "${GREEN}✅ Frontend deployed${NC}"
echo ""

# Step 10: Get frontend URL
echo -e "${YELLOW}Step 10: Getting frontend URL...${NC}"
FRONTEND_URL=$(gcloud run services describe $FRONTEND_SERVICE_NAME \
  --region $GCP_REGION \
  --format 'value(status.url)')
echo -e "${GREEN}✅ Frontend URL: $FRONTEND_URL${NC}"
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}║         ✅ DEPLOYMENT COMPLETE!                               ║${NC}"
echo -e "${BLUE}║                                                                ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}🎉 Your application is now live!${NC}"
echo ""
echo -e "${YELLOW}📱 Frontend (Next.js):${NC}"
echo -e "${GREEN}   $FRONTEND_URL${NC}"
echo ""
echo -e "${YELLOW}🔧 Backend (FastAPI):${NC}"
echo -e "${GREEN}   $BACKEND_URL${NC}"
echo ""
echo -e "${YELLOW}📊 Cloud Run Console:${NC}"
echo -e "${GREEN}   https://console.cloud.google.com/run?project=$GCP_PROJECT_ID${NC}"
echo ""
echo -e "${YELLOW}📝 View Logs:${NC}"
echo -e "${GREEN}   gcloud run logs read $BACKEND_SERVICE_NAME --region $GCP_REGION --follow${NC}"
echo -e "${GREEN}   gcloud run logs read $FRONTEND_SERVICE_NAME --region $GCP_REGION --follow${NC}"
echo ""
