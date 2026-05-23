# 📑 Google Cloud Run Deployment - Complete Index

## 🎯 Start Here

**New to Cloud Run?** Start with one of these:
1. **[GETTING_STARTED.md](GETTING_STARTED.md)** - Step-by-step guide for first-time deployment
2. **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Quick command reference card
3. **[README.md](README.md)** - Overview and quick start

---

## 📚 Documentation

### Getting Started
- **[GETTING_STARTED.md](GETTING_STARTED.md)** - Complete beginner's guide
  - Prerequisites setup
  - 3-step deployment process
  - Verification and testing
  - Troubleshooting common issues

### Comprehensive Guides
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Complete deployment guide
  - All deployment methods (scripts, manual, Terraform, CI/CD)
  - Detailed step-by-step instructions
  - Monitoring and troubleshooting
  - Cost optimization
  - Security considerations

- **[README.md](README.md)** - Quick reference
  - Architecture overview
  - Prerequisites
  - Quick start instructions
  - Common commands
  - Troubleshooting

### Quick Reference
- **[QUICK_REFERENCE.md](QUICK_REFERENCE.md)** - Command reference card
  - One-command deployment
  - Common commands
  - Troubleshooting matrix
  - Cost estimation
  - Resource limits

### Infrastructure as Code
- **[terraform/README.md](terraform/README.md)** - Terraform deployment guide
  - Setup and initialization
  - Configuration
  - Deployment
  - State management
  - Advanced configuration

---

## 🔧 Deployment Scripts

### Automated Deployment (Recommended)

**Windows:**
- **[setup-gcp.bat](setup-gcp.bat)** - Initialize GCP resources
- **[deploy-backend.bat](deploy-backend.bat)** - Deploy backend service
- **[deploy-frontend.bat](deploy-frontend.bat)** - Deploy frontend service
- **[deploy-all.bat](deploy-all.bat)** - Deploy both services

**Linux/Mac:**
- **[setup-gcp.sh](setup-gcp.sh)** - Initialize GCP resources
- **[deploy-backend.sh](deploy-backend.sh)** - Deploy backend service
- **[deploy-frontend.sh](deploy-frontend.sh)** - Deploy frontend service
- **[deploy-all.sh](deploy-all.sh)** - Deploy both services

### Infrastructure as Code

**Terraform:**
- **[terraform/main.tf](terraform/main.tf)** - Main Terraform configuration
- **[terraform/variables.tf](terraform/variables.tf)** - Variable definitions
- **[terraform/terraform.tfvars.example](terraform/terraform.tfvars.example)** - Example configuration

---

## ⚙️ Configuration Files

- **[cloud-run-config.yaml](cloud-run-config.yaml)** - Service configuration reference
- **[cloudbuild.yaml](cloudbuild.yaml)** - CI/CD pipeline configuration
- **[.env.gcp](.env.gcp)** - Generated configuration (created by setup script)

---

## 🚀 Deployment Methods

### Method 1: Automated Scripts (Fastest)
**Time:** ~10-15 minutes
```bash
./setup-gcp.sh
./deploy-all.sh
```
👉 See: [GETTING_STARTED.md](GETTING_STARTED.md)

### Method 2: Terraform (Production)
**Time:** ~10-15 minutes
```bash
cd terraform
terraform init
terraform apply
```
👉 See: [terraform/README.md](terraform/README.md)

### Method 3: Manual gcloud Commands
**Time:** ~20-30 minutes
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#manual-deployment)

### Method 4: CI/CD with Cloud Build
**Time:** ~15 minutes setup
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#cicd-with-cloud-build)

---

## 📋 Quick Navigation

### By Use Case

**I want to deploy quickly:**
→ [GETTING_STARTED.md](GETTING_STARTED.md)

**I need detailed instructions:**
→ [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

**I need a command reference:**
→ [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**I want to use Terraform:**
→ [terraform/README.md](terraform/README.md)

**I want to set up CI/CD:**
→ [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#cicd-with-cloud-build)

**I need to troubleshoot:**
→ [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#monitoring--troubleshooting)

### By Role

**DevOps Engineer:**
1. [terraform/README.md](terraform/README.md)
2. [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
3. [cloud-run-config.yaml](cloud-run-config.yaml)

**Developer:**
1. [GETTING_STARTED.md](GETTING_STARTED.md)
2. [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
3. [README.md](README.md)

**Project Manager:**
1. [README.md](README.md)
2. [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#cost-optimization)

---

## 🎯 Common Tasks

### Deploy Application
```bash
./deploy-all.sh  # or deploy-all.bat on Windows
```
👉 See: [GETTING_STARTED.md](GETTING_STARTED.md#step-3-deploy-services)

### View Logs
```bash
gcloud run logs read todo-backend --follow
```
👉 See: [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-common-commands)

### Update Environment Variables
```bash
gcloud run services update todo-backend --update-env-vars KEY=VALUE
```
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#update-environment-variables)

### Redeploy After Code Changes
```bash
./deploy-all.sh
```
👉 See: [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-typical-workflow)

### Delete Services
```bash
gcloud run services delete todo-backend
gcloud run services delete todo-frontend
```
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#cleanup)

### Rollback to Previous Version
```bash
gcloud run revisions list --service=todo-backend
gcloud run services update-traffic todo-backend --to-revisions=REVISION_NAME=100
```
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#rollback-procedure)

---

## 🆘 Troubleshooting

### Service fails to start
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#service-fails-to-start)

### Frontend can't reach backend
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#frontend-cant-reach-backend)

### Database connection issues
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#database-connection-issues)

### Other issues
👉 See: [QUICK_REFERENCE.md](QUICK_REFERENCE.md#-troubleshooting)

---

## 📊 Architecture & Design

### System Architecture
```
Frontend (Next.js) ←→ Backend (FastAPI) ←→ Neon PostgreSQL
```
👉 See: [README.md](README.md#architecture-overview)

### Deployment Architecture
```
Docker Images → Artifact Registry → Cloud Run Services
```
👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#architecture)

### Infrastructure as Code
```
Terraform → GCP Resources (Cloud Run, Artifact Registry, IAM)
```
👉 See: [terraform/README.md](terraform/README.md)

---

## 💰 Cost & Performance

### Cost Estimation
- Cloud Run: ~$5/month (1M requests)
- Artifact Registry: ~$0.10/month (1GB)
- Total: ~$5-10/month

👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#cost-optimization)

### Performance Optimization
- Auto-scaling: 0-10 instances
- Memory: 512Mi per service
- CPU: 1 per service
- Concurrency: 80 requests

👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#scaling--performance)

---

## 🔐 Security

### Security Checklist
- [ ] Never commit `.env` files
- [ ] Use Secret Manager for sensitive data
- [ ] Enable Cloud Armor for DDoS protection
- [ ] Set up IAM roles properly
- [ ] Enable Cloud Logging
- [ ] Rotate secrets regularly

👉 See: [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#security-best-practices)

---

## 📞 Support & Resources

### Official Documentation
- [Cloud Run Docs](https://cloud.google.com/run/docs)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)
- [Cloud Build](https://cloud.google.com/build/docs)
- [Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

### Getting Help
1. Check logs: `gcloud run logs read SERVICE_NAME --limit 100`
2. View details: `gcloud run services describe SERVICE_NAME`
3. Read guides: See documentation files above
4. GCP Console: https://console.cloud.google.com/run

---

## 📋 File Structure

```
infra/gcp/
├── 📄 INDEX.md                       ← You are here
├── 📄 GETTING_STARTED.md             ← Start here for first deployment
├── 📄 README.md                      ← Quick reference
├── 📄 DEPLOYMENT_GUIDE.md            ← Comprehensive guide
├── 📄 QUICK_REFERENCE.md             ← Command reference
├── 📄 cloud-run-config.yaml          ← Configuration reference
├── 📄 cloudbuild.yaml                ← CI/CD configuration
│
├── 🔧 Deployment Scripts (Linux/Mac)
│   ├── setup-gcp.sh
│   ├── deploy-backend.sh
│   ├── deploy-frontend.sh
│   └── deploy-all.sh
│
├── 🔧 Deployment Scripts (Windows)
│   ├── setup-gcp.bat
│   ├── deploy-backend.bat
│   ├── deploy-frontend.bat
│   └── deploy-all.bat
│
└── 📦 Terraform
    ├── main.tf
    ├── variables.tf
    ├── terraform.tfvars.example
    └── README.md
```

---

## ✅ Deployment Checklist

- [ ] Read [GETTING_STARTED.md](GETTING_STARTED.md)
- [ ] Install prerequisites
- [ ] Authenticate with gcloud
- [ ] Run setup script
- [ ] Run deploy script
- [ ] Verify services are running
- [ ] Test application
- [ ] Check logs
- [ ] Set up monitoring
- [ ] Configure custom domain (optional)

---

## 🎓 Learning Path

### Beginner
1. [GETTING_STARTED.md](GETTING_STARTED.md)
2. [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
3. [README.md](README.md)

### Intermediate
1. [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
2. [cloud-run-config.yaml](cloud-run-config.yaml)
3. [cloudbuild.yaml](cloudbuild.yaml)

### Advanced
1. [terraform/README.md](terraform/README.md)
2. [terraform/main.tf](terraform/main.tf)
3. [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md#cicd-with-cloud-build)

---

## 🚀 Quick Start Commands

```bash
# Setup (one-time)
./setup-gcp.sh

# Deploy
./deploy-all.sh

# View logs
gcloud run logs read todo-backend --follow

# View services
gcloud run services list --region us-central1

# Update env var
gcloud run services update todo-backend --update-env-vars KEY=VALUE

# Delete services
gcloud run services delete todo-backend
gcloud run services delete todo-frontend
```

---

## 📞 Need Help?

1. **Quick answers:** [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
2. **Detailed help:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)
3. **Getting started:** [GETTING_STARTED.md](GETTING_STARTED.md)
4. **Terraform help:** [terraform/README.md](terraform/README.md)
5. **GCP Support:** https://cloud.google.com/support

---

**Last Updated:** May 2026
**Version:** 1.0
**Status:** Production Ready ✅

---

## 🎉 Ready to Deploy?

Choose your deployment method:
- **Fastest:** [GETTING_STARTED.md](GETTING_STARTED.md)
- **Production:** [terraform/README.md](terraform/README.md)
- **Detailed:** [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)

**Happy Deploying! 🚀**
