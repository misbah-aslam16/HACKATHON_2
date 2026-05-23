# 🚀 Getting Started with Cloud Run Deployment

Welcome! This guide will walk you through deploying your Todo Fullstack application to Google Cloud Run in minutes.

## 📋 Prerequisites (5 minutes)

### 1. Create a Google Cloud Account
- Go to [Google Cloud Console](https://console.cloud.google.com)
- Create a new project
- Enable billing

### 2. Install Required Tools

**Windows:**
```powershell
# Install Google Cloud SDK
# Download from: https://cloud.google.com/sdk/docs/install

# Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# Verify installations
gcloud --version
docker --version
```

**Mac:**
```bash
# Install Google Cloud SDK
brew install google-cloud-sdk

# Install Docker Desktop
brew install --cask docker

# Verify installations
gcloud --version
docker --version
```

**Linux:**
```bash
# Install Google Cloud SDK
curl https://sdk.cloud.google.com | bash

# Install Docker
sudo apt-get install docker.io

# Verify installations
gcloud --version
docker --version
```

### 3. Authenticate with Google Cloud

```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

---

## 🎯 Deployment in 3 Steps

### Step 1: Navigate to Deployment Directory

**Windows:**
```batch
cd infra\gcp
```

**Linux/Mac:**
```bash
cd infra/gcp
chmod +x *.sh
```

### Step 2: Run Setup

**Windows:**
```batch
setup-gcp.bat
```

**Linux/Mac:**
```bash
./setup-gcp.sh
```

This will:
- ✅ Enable required GCP APIs
- ✅ Create Artifact Registry repository
- ✅ Configure Docker authentication
- ✅ Generate `.env.gcp` configuration

### Step 3: Deploy Services

**Windows:**
```batch
deploy-all.bat
```

**Linux/Mac:**
```bash
./deploy-all.sh
```

This will:
- ✅ Build backend Docker image
- ✅ Build frontend Docker image
- ✅ Push images to Artifact Registry
- ✅ Deploy backend to Cloud Run
- ✅ Deploy frontend to Cloud Run

---

## ✅ Verify Deployment

After deployment completes, you should see:

```
Backend Service:
  Name: todo-backend
  URL: https://todo-backend-xxxxx.run.app
  Region: us-central1

Frontend Service:
  Name: todo-frontend
  URL: https://todo-frontend-xxxxx.run.app
  Region: us-central1
```

### Test Your Application

1. Open the frontend URL in your browser
2. You should see your Todo application
3. Test creating, reading, updating, and deleting todos

### View Logs

```bash
# Backend logs
gcloud run logs read todo-backend --region us-central1 --limit 50

# Frontend logs
gcloud run logs read todo-frontend --region us-central1 --limit 50
```

---

## 🎓 Understanding What Was Deployed

### Architecture

```
Your Browser
    │
    ▼
┌─────────────────────────────────────┐
│  Frontend (Next.js)                 │
│  https://todo-frontend-xxxxx.run.app│
│  Port: 3000                         │
└─────────────────────────────────────┘
    │
    │ API Calls
    ▼
┌─────────────────────────────────────┐
│  Backend (FastAPI)                  │
│  https://todo-backend-xxxxx.run.app │
│  Port: 8080                         │
└─────────────────────────────────────┘
    │
    │ Database Queries
    ▼
┌─────────────────────────────────────┐
│  Neon PostgreSQL Database           │
│  (External, already configured)     │
└─────────────────────────────────────┘
```

### Services Deployed

| Service | Framework | Memory | CPU | Instances |
|---------|-----------|--------|-----|-----------|
| Backend | FastAPI | 512Mi | 1 | 0-10 |
| Frontend | Next.js | 512Mi | 1 | 0-10 |

---

## 🔧 Common Tasks

### View All Services

```bash
gcloud run services list --region us-central1
```

### View Service Details

```bash
gcloud run services describe todo-backend --region us-central1
```

### Update Environment Variables

```bash
gcloud run services update todo-backend --region us-central1 \
  --update-env-vars DATABASE_URL="new-value"
```

### View Real-time Logs

```bash
gcloud run logs read todo-backend --region us-central1 --follow
```

### Redeploy After Code Changes

```bash
./deploy-all.sh  # or deploy-all.bat on Windows
```

### Delete Services

```bash
gcloud run services delete todo-backend --region us-central1
gcloud run services delete todo-frontend --region us-central1
```

---

## 🐛 Troubleshooting

### Issue: "gcloud: command not found"

**Solution:** Install Google Cloud SDK
- Windows: https://cloud.google.com/sdk/docs/install-sdk#windows
- Mac: `brew install google-cloud-sdk`
- Linux: `curl https://sdk.cloud.google.com | bash`

### Issue: "docker: command not found"

**Solution:** Install Docker Desktop
- https://www.docker.com/products/docker-desktop

### Issue: "Permission denied" or "Not authenticated"

**Solution:** Authenticate with Google Cloud
```bash
gcloud auth login
gcloud config set project YOUR_PROJECT_ID
```

### Issue: Service fails to start

**Solution:** Check logs
```bash
gcloud run logs read SERVICE_NAME --region us-central1 --limit 100
```

### Issue: Frontend can't reach backend

**Solution:** Verify environment variables
```bash
gcloud run services describe todo-frontend --region us-central1 \
  --format='value(spec.template.spec.containers[0].env)'
```

### Issue: Database connection error

**Solution:** Verify connection string
1. Check `.env` file has correct `DATABASE_URL`
2. Ensure Neon database is accessible
3. Verify connection string format

---

## 💡 Tips & Best Practices

### 1. Monitor Your Costs
- Cloud Run is very cost-effective
- Estimated cost: $5-10/month for small apps
- Use Cloud Console to monitor usage

### 2. Keep Logs Clean
- Regularly review logs for errors
- Set up alerts for high error rates
- Archive old logs

### 3. Update Regularly
- Redeploy after code changes
- Keep dependencies updated
- Monitor security advisories

### 4. Backup Your Data
- Neon provides automated backups
- Set retention policy
- Test restore procedures

### 5. Use Custom Domain (Optional)
```bash
gcloud run domain-mappings create \
  --service=todo-frontend \
  --domain=yourdomain.com \
  --region=us-central1
```

---

## 📚 Next Steps

### Immediate
- [ ] Verify services are running
- [ ] Test application functionality
- [ ] Check logs for errors

### Short-term (This Week)
- [ ] Set up monitoring and alerts
- [ ] Configure custom domain
- [ ] Enable Cloud CDN

### Long-term (This Month)
- [ ] Set up CI/CD pipeline
- [ ] Implement backup strategy
- [ ] Optimize resource allocation

---

## 📖 Documentation

| Document | Purpose |
|----------|---------|
| `README.md` | Quick reference |
| `DEPLOYMENT_GUIDE.md` | Comprehensive guide |
| `QUICK_REFERENCE.md` | Command reference |
| `terraform/README.md` | Terraform guide |

---

## 🆘 Getting Help

### 1. Check Logs
```bash
gcloud run logs read SERVICE_NAME --region us-central1 --limit 100
```

### 2. View Service Details
```bash
gcloud run services describe SERVICE_NAME --region us-central1
```

### 3. Read Documentation
- See `DEPLOYMENT_GUIDE.md` for detailed steps
- See `QUICK_REFERENCE.md` for common commands
- See `terraform/README.md` for Terraform help

### 4. Google Cloud Support
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Cloud Run Troubleshooting](https://cloud.google.com/run/docs/troubleshooting)
- [Google Cloud Support](https://cloud.google.com/support)

---

## 🎉 Congratulations!

Your Todo Fullstack application is now running on Google Cloud Run! 🚀

### What You've Accomplished
✅ Set up Google Cloud infrastructure
✅ Created Docker images for backend and frontend
✅ Deployed services to Cloud Run
✅ Configured environment variables
✅ Set up monitoring and logging

### What's Next?
- Monitor your application
- Make code changes and redeploy
- Set up custom domain
- Implement CI/CD pipeline
- Optimize costs and performance

---

## 📞 Quick Reference

```bash
# View services
gcloud run services list --region us-central1

# View logs
gcloud run logs read todo-backend --follow

# Update env var
gcloud run services update todo-backend --update-env-vars KEY=VALUE

# Redeploy
./deploy-all.sh

# Delete services
gcloud run services delete todo-backend
gcloud run services delete todo-frontend
```

---

## 🎓 Learning Resources

- [Cloud Run Quickstart](https://cloud.google.com/run/docs/quickstarts/build-and-deploy)
- [Cloud Run Best Practices](https://cloud.google.com/run/docs/tips/general-tips)
- [Artifact Registry Guide](https://cloud.google.com/artifact-registry/docs)
- [gcloud CLI Reference](https://cloud.google.com/sdk/gcloud/reference)

---

**Last Updated:** May 2026
**Version:** 1.0

**Happy Deploying! 🚀**

---

## 📋 Deployment Checklist

- [ ] Google Cloud SDK installed
- [ ] Docker installed
- [ ] GCP account created
- [ ] Billing enabled
- [ ] Authenticated with gcloud
- [ ] Ran setup-gcp script
- [ ] Ran deploy-all script
- [ ] Services deployed successfully
- [ ] Verified frontend URL works
- [ ] Checked logs for errors
- [ ] Tested application functionality

---

**Questions?** Check the comprehensive guides in the `infra/gcp/` directory.
