# Complete Cloud Run Deployment Guide

Deploy your Todo Fullstack application to Google Cloud Run with this comprehensive guide.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Start (Bash Scripts)](#quick-start-bash-scripts)
3. [Manual Deployment](#manual-deployment)
4. [Terraform Deployment](#terraform-deployment)
5. [CI/CD with Cloud Build](#cicd-with-cloud-build)
6. [Monitoring & Troubleshooting](#monitoring--troubleshooting)
7. [Cost Optimization](#cost-optimization)

---

## Prerequisites

### Required Tools

- **gcloud CLI** - [Install](https://cloud.google.com/sdk/docs/install)
- **Docker** - [Install](https://docs.docker.com/get-docker/)
- **Git** - [Install](https://git-scm.com/downloads)

### GCP Setup

1. Create a GCP project
2. Enable billing
3. Note your Project ID

### Environment Variables

Gather these from your `.env` files:

```bash
DATABASE_URL=postgresql://...
DATABASE_URL_UNPOOLED=postgresql://...
AUTH_SECRET=...
BETTER_AUTH_SECRET=...
```

---

## Quick Start (Bash Scripts)

### Step 1: Initialize GCP

```bash
cd infra/gcp
chmod +x *.sh
./setup-gcp.sh
```

Follow the prompts to:
- Authenticate with GCP
- Set your project ID
- Create Artifact Registry repository
- Configure Docker authentication

### Step 2: Deploy Services

```bash
# Deploy both backend and frontend
./deploy-all.sh

# Or deploy individually
./deploy-backend.sh
./deploy-frontend.sh
```

### Step 3: Verify Deployment

```bash
# Get service URLs
gcloud run services list --region us-central1

# View logs
gcloud run logs read todo-backend --region us-central1 --limit 50
gcloud run logs read todo-frontend --region us-central1 --limit 50
```

---

## Manual Deployment

### Step 1: Authenticate

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Step 2: Enable APIs

```bash
gcloud services enable \
  run.googleapis.com \
  artifactregistry.googleapis.com \
  cloudbuild.googleapis.com
```

### Step 3: Create Artifact Registry

```bash
gcloud artifacts repositories create todo-app \
  --repository-format=docker \
  --location=us-central1 \
  --description="Todo App Docker Images"
```

### Step 4: Configure Docker

```bash
gcloud auth configure-docker us-central1-docker.pkg.dev
```

### Step 5: Build Backend Image

```bash
docker build -f infra/docker/Dockerfile.backend \
  -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/todo-app/backend:latest .

docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/todo-app/backend:latest
```

### Step 6: Deploy Backend

```bash
gcloud run deploy todo-backend \
  --image us-central1-docker.pkg.dev/YOUR_PROJECT_ID/todo-app/backend:latest \
  --platform managed \
  --region us-central1 \
  --memory 512Mi \
  --cpu 1 \
  --allow-unauthenticated \
  --set-env-vars \
    DATABASE_URL="$DATABASE_URL",\
    DATABASE_URL_UNPOOLED="$DATABASE_URL_UNPOOLED",\
    PORT=8080
```

### Step 7: Get Backend URL

```bash
BACKEND_URL=$(gcloud run services describe todo-backend \
  --region us-central1 \
  --format 'value(status.url)')

echo $BACKEND_URL
```

### Step 8: Build Frontend Image

```bash
docker build -f infra/docker/Dockerfile.frontend \
  --build-arg NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL \
  -t us-central1-docker.pkg.dev/YOUR_PROJECT_ID/todo-app/frontend:latest .

docker push us-central1-docker.pkg.dev/YOUR_PROJECT_ID/todo-app/frontend:latest
```

### Step 9: Deploy Frontend

```bash
gcloud run deploy todo-frontend \
  --image us-central1-docker.pkg.dev/YOUR_PROJECT_ID/todo-app/frontend:latest \
  --platform managed \
  --region us-central1 \
  --memory 512Mi \
  --cpu 1 \
  --allow-unauthenticated \
  --set-env-vars \
    NEXT_PUBLIC_BACKEND_URL="$BACKEND_URL",\
    DATABASE_URL="$DATABASE_URL",\
    DATABASE_URL_UNPOOLED="$DATABASE_URL_UNPOOLED",\
    AUTH_SECRET="$AUTH_SECRET",\
    BETTER_AUTH_SECRET="$BETTER_AUTH_SECRET",\
    PORT=3000
```

---

## Terraform Deployment

### Step 1: Initialize Terraform

```bash
cd infra/gcp/terraform
terraform init
```

### Step 2: Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit with your values:

```hcl
gcp_project_id = "your-project-id"
gcp_region     = "us-central1"

database_url          = "postgresql://..."
database_url_unpooled = "postgresql://..."
auth_secret           = "..."
better_auth_secret    = "..."
```

### Step 3: Plan & Apply

```bash
terraform plan
terraform apply
```

### Step 4: Get Outputs

```bash
terraform output backend_url
terraform output frontend_url
```

---

## CI/CD with Cloud Build

### Step 1: Connect Repository

```bash
gcloud builds connect --repository-name=HACKATHON_2 \
  --repository-owner=YOUR_GITHUB_USERNAME \
  --region=us-central1
```

### Step 2: Create Cloud Build Trigger

```bash
gcloud builds triggers create github \
  --name="todo-app-deploy" \
  --repo-name=HACKATHON_2 \
  --repo-owner=YOUR_GITHUB_USERNAME \
  --branch-pattern="^main$" \
  --build-config=infra/gcp/cloudbuild.yaml \
  --substitutions=_REGION=us-central1,_ARTIFACT_REGISTRY_REPO=todo-app
```

### Step 3: Set Secrets in Cloud Build

```bash
# Create secrets
echo -n "$DATABASE_URL" | gcloud secrets create database-url --data-file=-
echo -n "$DATABASE_URL_UNPOOLED" | gcloud secrets create database-url-unpooled --data-file=-
echo -n "$AUTH_SECRET" | gcloud secrets create auth-secret --data-file=-
echo -n "$BETTER_AUTH_SECRET" | gcloud secrets create better-auth-secret --data-file=-

# Grant Cloud Build access
gcloud secrets add-iam-policy-binding database-url \
  --member=serviceAccount:PROJECT_NUMBER@cloudbuild.gserviceaccount.com \
  --role=roles/secretmanager.secretAccessor
```

### Step 4: Update cloudbuild.yaml

Reference secrets in `cloudbuild.yaml`:

```yaml
substitutions:
  _DATABASE_URL: '${database-url}'
  _DATABASE_URL_UNPOOLED: '${database-url-unpooled}'
  _AUTH_SECRET: '${auth-secret}'
  _BETTER_AUTH_SECRET: '${better-auth-secret}'
```

---

## Monitoring & Troubleshooting

### View Logs

```bash
# Real-time logs
gcloud run logs read todo-backend --region us-central1 --follow

# Last 50 lines
gcloud run logs read todo-backend --region us-central1 --limit 50

# Specific time range
gcloud run logs read todo-backend --region us-central1 \
  --min-log-level=ERROR \
  --limit 100
```

### Check Service Status

```bash
gcloud run services describe todo-backend --region us-central1

gcloud run services describe todo-frontend --region us-central1
```

### Common Issues

#### Service fails to start

```bash
# Check logs for errors
gcloud run logs read todo-backend --region us-central1 --limit 100

# Verify environment variables
gcloud run services describe todo-backend --region us-central1 \
  --format='value(spec.template.spec.containers[0].env)'
```

#### Frontend can't reach backend

```bash
# Verify NEXT_PUBLIC_BACKEND_URL
gcloud run services describe todo-frontend --region us-central1 \
  --format='value(spec.template.spec.containers[0].env[?name==`NEXT_PUBLIC_BACKEND_URL`].value)'

# Update if needed
gcloud run services update todo-frontend --region us-central1 \
  --update-env-vars NEXT_PUBLIC_BACKEND_URL=https://todo-backend-xxxxx.run.app
```

#### Database connection issues

```bash
# Test connection from Cloud Shell
gcloud cloud-shell ssh --command="psql $DATABASE_URL"

# Check if Neon allows Cloud Run IPs
# (Neon should allow all IPs by default)
```

---

## Cost Optimization

### Memory & CPU

```bash
# Start with 512Mi/1 CPU
# Monitor usage and adjust if needed

# View metrics
gcloud monitoring time-series list \
  --filter='resource.type="cloud_run_revision"'
```

### Scaling

```bash
# Set min instances to 0 (default)
# Set max instances to 10 (adjust based on traffic)

gcloud run services update todo-backend --region us-central1 \
  --min-instances=0 \
  --max-instances=10
```

### Cloud CDN

```bash
# Enable CDN for frontend
gcloud compute backend-services create frontend-cdn \
  --protocol=HTTPS \
  --enable-cdn
```

### Estimated Costs

- **Cloud Run**: ~$0.00002400 per vCPU-second
- **Artifact Registry**: $0.10 per GB stored
- **Cloud Build**: $0.003 per build minute

For a typical small app:
- 1M requests/month: ~$5-10
- Storage: ~$1-2
- Build: ~$1-2

---

## Next Steps

1. **Set up custom domain**
   ```bash
   gcloud run domain-mappings create --service=todo-frontend \
     --domain=yourdomain.com --region=us-central1
   ```

2. **Enable Cloud Armor**
   ```bash
   gcloud compute security-policies create todo-app-policy
   ```

3. **Set up monitoring alerts**
   ```bash
   gcloud alpha monitoring policies create \
     --notification-channels=CHANNEL_ID \
     --display-name="High Error Rate"
   ```

4. **Configure backup strategy**
   - Use Neon's automated backups
   - Set retention policy

5. **Enable VPC Service Controls**
   - Restrict data exfiltration
   - Enforce security perimeter

---

## Support & Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Artifact Registry Guide](https://cloud.google.com/artifact-registry/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

---

## Rollback Procedure

If deployment fails:

```bash
# View previous revisions
gcloud run revisions list --service=todo-backend --region=us-central1

# Route traffic to previous revision
gcloud run services update-traffic todo-backend \
  --to-revisions=REVISION_NAME=100 \
  --region=us-central1
```

---

**Last Updated**: May 2026
**Maintained By**: DevOps Team
