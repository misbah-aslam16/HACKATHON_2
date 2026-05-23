# Google Cloud Run Deployment - Complete Setup

Your Todo Fullstack application is ready for deployment to Google Cloud Run. This document provides a complete overview of the deployment infrastructure.

## 📋 What's Included

### 1. **Deployment Scripts**
- **Bash Scripts** (Linux/Mac):
  - `setup-gcp.sh` - Initialize GCP resources
  - `deploy-backend.sh` - Deploy backend service
  - `deploy-frontend.sh` - Deploy frontend service
  - `deploy-all.sh` - Deploy both services

- **Batch Scripts** (Windows):
  - `setup-gcp.bat` - Initialize GCP resources
  - `deploy-backend.bat` - Deploy backend service
  - `deploy-frontend.bat` - Deploy frontend service
  - `deploy-all.bat` - Deploy both services

### 2. **Infrastructure as Code**
- **Terraform** (`infra/gcp/terraform/`):
  - `main.tf` - Cloud Run services, Artifact Registry, IAM
  - `variables.tf` - Configuration variables
  - `terraform.tfvars.example` - Example configuration

### 3. **CI/CD Pipeline**
- `cloudbuild.yaml` - Google Cloud Build configuration for automated deployments

### 4. **Configuration Files**
- `cloud-run-config.yaml` - Service configuration reference
- `.env.gcp` - Generated during setup with your configuration

### 5. **Documentation**
- `README.md` - Quick reference guide
- `DEPLOYMENT_GUIDE.md` - Comprehensive deployment guide
- `terraform/README.md` - Terraform-specific guide

## 🚀 Quick Start (Choose One Method)

### Method 1: Automated Scripts (Recommended for Quick Setup)

#### On Windows:
```bash
cd infra/gcp
setup-gcp.bat
deploy-all.bat
```

#### On Linux/Mac:
```bash
cd infra/gcp
chmod +x *.sh
./setup-gcp.sh
./deploy-all.sh
```

### Method 2: Terraform (Recommended for Production)

```bash
cd infra/gcp/terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
terraform init
terraform plan
terraform apply
```

### Method 3: Manual gcloud Commands

See `DEPLOYMENT_GUIDE.md` for step-by-step manual deployment.

## 📦 Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    Google Cloud Run                      │
├─────────────────────────────────────────────────────────┤
│                                                           │
│  ┌──────────────────┐          ┌──────────────────┐    │
│  │  Frontend        │          │  Backend         │    │
│  │  (Next.js)       │◄────────►│  (FastAPI)       │    │
│  │  Port: 3000      │          │  Port: 8080      │    │
│  │  512Mi / 1 CPU   │          │  512Mi / 1 CPU   │    │
│  └──────────────────┘          └──────────────────┘    │
│                                         │                │
│                                         ▼                │
│                                  ┌──────────────┐       │
│                                  │ Neon DB      │       │
│                                  │ PostgreSQL   │       │
│                                  └──────────────┘       │
│                                                           │
└─────────────────────────────────────────────────────────┘
```

## 🔧 Prerequisites

### Required
- Google Cloud Account with billing enabled
- gcloud CLI installed
- Docker installed
- Git installed

### Optional
- Terraform (for IaC deployment)
- Cloud Build (for CI/CD)

## 📝 Configuration

### Environment Variables Required

**Backend:**
```
DATABASE_URL=postgresql://...
DATABASE_URL_UNPOOLED=postgresql://...
PORT=8080
```

**Frontend:**
```
NEXT_PUBLIC_BACKEND_URL=https://todo-backend-xxxxx.run.app
DATABASE_URL=postgresql://...
DATABASE_URL_UNPOOLED=postgresql://...
AUTH_SECRET=...
BETTER_AUTH_SECRET=...
PORT=3000
```

These are automatically read from your existing `.env` files during deployment.

## 📊 Resource Configuration

| Resource | Memory | CPU | Max Instances | Timeout |
|----------|--------|-----|---------------|---------|
| Backend | 512Mi | 1 | 10 | 3600s |
| Frontend | 512Mi | 1 | 10 | 3600s |

Adjust in `.env.gcp` or `terraform.tfvars` as needed.

## 💰 Estimated Costs

- **Cloud Run**: ~$0.00002400 per vCPU-second
- **Artifact Registry**: $0.10 per GB stored
- **Cloud Build**: $0.003 per build minute

For a typical small app with 1M requests/month: **~$5-10/month**

## 🔍 Monitoring & Logs

### View Logs
```bash
# Backend logs
gcloud run logs read todo-backend --region us-central1 --limit 50

# Frontend logs
gcloud run logs read todo-frontend --region us-central1 --limit 50

# Real-time logs
gcloud run logs read todo-backend --region us-central1 --follow
```

### View Service Status
```bash
gcloud run services describe todo-backend --region us-central1
gcloud run services describe todo-frontend --region us-central1
```

### Update Environment Variables
```bash
gcloud run services update todo-backend --region us-central1 \
  --update-env-vars KEY=VALUE
```

## 🛠️ Troubleshooting

### Service fails to start
1. Check logs: `gcloud run logs read SERVICE_NAME --region us-central1 --limit 100`
2. Verify environment variables are set correctly
3. Ensure database connection string is valid

### Frontend can't reach backend
1. Verify `NEXT_PUBLIC_BACKEND_URL` is set to the backend Cloud Run URL
2. Check CORS settings in backend
3. Ensure both services are deployed and running

### Database connection issues
1. Verify Neon database is accessible
2. Check connection string format
3. Ensure firewall rules allow Cloud Run IPs

## 📚 File Structure

```
infra/gcp/
├── README.md                          # Quick reference
├── DEPLOYMENT_GUIDE.md                # Comprehensive guide
├── setup-gcp.sh                       # Setup script (Linux/Mac)
├── setup-gcp.bat                      # Setup script (Windows)
├── deploy-backend.sh                  # Backend deployment (Linux/Mac)
├── deploy-backend.bat                 # Backend deployment (Windows)
├── deploy-frontend.sh                 # Frontend deployment (Linux/Mac)
├── deploy-frontend.bat                # Frontend deployment (Windows)
├── deploy-all.sh                      # Full deployment (Linux/Mac)
├── deploy-all.bat                     # Full deployment (Windows)
├── cloud-run-config.yaml              # Service configuration reference
├── cloudbuild.yaml                    # CI/CD pipeline configuration
├── .env.gcp                           # Generated configuration (after setup)
└── terraform/
    ├── main.tf                        # Terraform main configuration
    ├── variables.tf                   # Terraform variables
    ├── terraform.tfvars.example       # Example variables
    └── README.md                      # Terraform guide
```

## 🔐 Security Best Practices

1. **Secrets Management**
   - Use Google Secret Manager for sensitive data
   - Never commit `.env` files to version control
   - Rotate secrets regularly

2. **Access Control**
   - Use Cloud IAM for fine-grained access control
   - Enable Cloud Armor for DDoS protection
   - Use VPC Service Controls for data exfiltration prevention

3. **Monitoring**
   - Enable Cloud Logging for audit trails
   - Set up Cloud Monitoring alerts
   - Use Cloud Trace for performance analysis

## 🚢 CI/CD Integration

### GitHub Actions
Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Cloud Run
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Deploy
        run: |
          cd infra/gcp
          ./deploy-all.sh
```

### Cloud Build
```bash
gcloud builds submit --config=infra/gcp/cloudbuild.yaml
```

## 📈 Scaling & Performance

### Auto-scaling
Cloud Run automatically scales based on traffic:
- Min instances: 0 (default)
- Max instances: 10 (configurable)
- Concurrency: 80 (default)

### Performance Optimization
1. Use Cloud CDN for frontend caching
2. Enable Cloud Armor for DDoS protection
3. Monitor and adjust memory/CPU as needed
4. Use connection pooling for database

## 🔄 Rollback Procedure

If deployment fails:
```bash
# View previous revisions
gcloud run revisions list --service=todo-backend --region=us-central1

# Route traffic to previous revision
gcloud run services update-traffic todo-backend \
  --to-revisions=REVISION_NAME=100 \
  --region=us-central1
```

## 🧹 Cleanup

To delete all resources:
```bash
# Delete services
gcloud run services delete todo-backend --region us-central1
gcloud run services delete todo-frontend --region us-central1

# Delete Artifact Registry
gcloud artifacts repositories delete todo-app --location=us-central1

# Delete Terraform resources
cd infra/gcp/terraform
terraform destroy
```

## 📞 Support & Resources

- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Artifact Registry Guide](https://cloud.google.com/artifact-registry/docs)
- [Cloud Build Documentation](https://cloud.google.com/build/docs)
- [Terraform Google Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [Neon Database Documentation](https://neon.tech/docs)

## ✅ Deployment Checklist

- [ ] GCP account created and billing enabled
- [ ] gcloud CLI installed and authenticated
- [ ] Docker installed and running
- [ ] Database credentials verified
- [ ] Environment variables configured
- [ ] Backend deployed successfully
- [ ] Frontend deployed successfully
- [ ] Services accessible via URLs
- [ ] Logs verified for errors
- [ ] Monitoring alerts configured
- [ ] Backup strategy implemented
- [ ] Custom domain configured (optional)

## 🎯 Next Steps

1. **Immediate**
   - Deploy using scripts or Terraform
   - Verify services are running
   - Test application functionality

2. **Short-term**
   - Set up monitoring and alerts
   - Configure custom domain
   - Enable Cloud CDN

3. **Long-term**
   - Implement CI/CD pipeline
   - Set up backup strategy
   - Optimize costs
   - Plan for scaling

---

**Last Updated**: May 2026
**Version**: 1.0
**Status**: Production Ready

For questions or issues, refer to the comprehensive `DEPLOYMENT_GUIDE.md` or contact your DevOps team.
