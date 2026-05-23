# Google Cloud Run Deployment Guide

This directory contains all necessary files and scripts to deploy the Todo Fullstack application to Google Cloud Run.

## Architecture Overview

- **Backend**: FastAPI service running on Cloud Run (port 8080)
- **Frontend**: Next.js service running on Cloud Run (port 3000)
- **Database**: Neon PostgreSQL (external, already configured)
- **Container Registry**: Google Artifact Registry

## Prerequisites

1. **Google Cloud Account** with billing enabled
2. **gcloud CLI** installed and configured
3. **Docker** installed locally
4. **Project ID** from GCP
5. **Neon Database** credentials (already in .env files)

## Quick Start

### 1. Set Environment Variables

```bash
export GCP_PROJECT_ID="your-project-id"
export GCP_REGION="us-central1"
export ARTIFACT_REGISTRY_REPO="todo-app"
export ARTIFACT_REGISTRY_REGION="us-central1"
```

### 2. Authenticate with GCP

```bash
gcloud auth login
gcloud config set project $GCP_PROJECT_ID
```

### 3. Create Artifact Registry Repository

```bash
gcloud artifacts repositories create $ARTIFACT_REGISTRY_REPO \
  --repository-format=docker \
  --location=$ARTIFACT_REGISTRY_REGION \
  --description="Todo App Docker Images"
```

### 4. Configure Docker Authentication

```bash
gcloud auth configure-docker $ARTIFACT_REGISTRY_REGION-docker.pkg.dev
```

### 5. Build and Push Images

```bash
# Backend
docker build -f infra/docker/Dockerfile.backend \
  -t $ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO/backend:latest .

docker push $ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO/backend:latest

# Frontend
docker build -f infra/docker/Dockerfile.frontend \
  -t $ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO/frontend:latest .

docker push $ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO/frontend:latest
```

### 6. Deploy Backend to Cloud Run

```bash
gcloud run deploy todo-backend \
  --image $ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO/backend:latest \
  --platform managed \
  --region $GCP_REGION \
  --memory 512Mi \
  --cpu 1 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated \
  --set-env-vars DATABASE_URL=$DATABASE_URL,DATABASE_URL_UNPOOLED=$DATABASE_URL_UNPOOLED
```

### 7. Deploy Frontend to Cloud Run

```bash
# Get backend URL from previous deployment
BACKEND_URL=$(gcloud run services describe todo-backend --region $GCP_REGION --format 'value(status.url)')

gcloud run deploy todo-frontend \
  --image $ARTIFACT_REGISTRY_REGION-docker.pkg.dev/$GCP_PROJECT_ID/$ARTIFACT_REGISTRY_REPO/frontend:latest \
  --platform managed \
  --region $GCP_REGION \
  --memory 512Mi \
  --cpu 1 \
  --timeout 3600 \
  --max-instances 10 \
  --allow-unauthenticated \
  --set-env-vars NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL,NEXT_PUBLIC_APP_URL=https://todo-frontend-xxxxx.run.app,DATABASE_URL=$DATABASE_URL,DATABASE_URL_UNPOOLED=$DATABASE_URL_UNPOOLED,AUTH_SECRET=$AUTH_SECRET,BETTER_AUTH_SECRET=$BETTER_AUTH_SECRET
```

## Automated Deployment Scripts

Use the provided scripts for easier deployment:

- `deploy-backend.sh` - Deploy backend service
- `deploy-frontend.sh` - Deploy frontend service
- `deploy-all.sh` - Deploy both services
- `setup-gcp.sh` - Initial GCP setup

## Environment Variables

Required environment variables for Cloud Run:

**Backend:**
- `DATABASE_URL` - Neon pooled connection string
- `DATABASE_URL_UNPOOLED` - Neon unpooled connection string
- `PORT` - Set to 8080 (Cloud Run requirement)

**Frontend:**
- `NEXT_PUBLIC_BACKEND_URL` - Backend Cloud Run URL
- `NEXT_PUBLIC_APP_URL` - Frontend Cloud Run URL
- `DATABASE_URL` - Neon pooled connection string
- `DATABASE_URL_UNPOOLED` - Neon unpooled connection string
- `AUTH_SECRET` - Authentication secret
- `BETTER_AUTH_SECRET` - Better Auth secret

## Monitoring & Logs

View logs:
```bash
gcloud run logs read todo-backend --region $GCP_REGION --limit 50
gcloud run logs read todo-frontend --region $GCP_REGION --limit 50
```

View service details:
```bash
gcloud run services describe todo-backend --region $GCP_REGION
gcloud run services describe todo-frontend --region $GCP_REGION
```

## Cost Optimization

- **Memory**: Start with 512Mi, scale up if needed
- **CPU**: 1 CPU is sufficient for most workloads
- **Max Instances**: Set to 10 to control costs
- **Concurrency**: Default 80 is fine for most cases

## Troubleshooting

### Service fails to start
- Check logs: `gcloud run logs read SERVICE_NAME --region $GCP_REGION`
- Verify environment variables are set correctly
- Ensure database connection string is valid

### Frontend can't reach backend
- Verify `NEXT_PUBLIC_BACKEND_URL` is set to the backend Cloud Run URL
- Check CORS settings in backend

### Database connection issues
- Verify Neon database is accessible from Cloud Run
- Check connection string format
- Ensure firewall rules allow Cloud Run IPs

## Next Steps

1. Set up Cloud SQL Proxy if using Cloud SQL instead of Neon
2. Configure custom domain with Cloud Run
3. Set up CI/CD pipeline with Cloud Build
4. Enable Cloud Armor for DDoS protection
5. Configure Cloud CDN for frontend caching
