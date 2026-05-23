# Cloud Run Deployment - Quick Reference Card

## 🚀 One-Command Deployment

### Windows
```batch
cd infra\gcp
setup-gcp.bat
deploy-all.bat
```

### Linux/Mac
```bash
cd infra/gcp
chmod +x *.sh
./setup-gcp.sh
./deploy-all.sh
```

---

## 📋 Prerequisites Checklist

- [ ] GCP account with billing enabled
- [ ] `gcloud` CLI installed: `gcloud --version`
- [ ] Docker installed: `docker --version`
- [ ] Authenticated: `gcloud auth login`

---

## 🔑 Key Environment Variables

From your `.env` files:
```
DATABASE_URL=postgresql://...
DATABASE_URL_UNPOOLED=postgresql://...
AUTH_SECRET=...
BETTER_AUTH_SECRET=...
```

---

## 📊 Service URLs After Deployment

```
Backend:  https://todo-backend-xxxxx.run.app
Frontend: https://todo-frontend-xxxxx.run.app
```

Get them with:
```bash
gcloud run services list --region us-central1
```

---

## 🔍 Common Commands

### View Logs
```bash
# Backend
gcloud run logs read todo-backend --region us-central1 --limit 50

# Frontend
gcloud run logs read todo-frontend --region us-central1 --limit 50

# Real-time
gcloud run logs read todo-backend --region us-central1 --follow
```

### Update Environment Variables
```bash
gcloud run services update todo-backend --region us-central1 \
  --update-env-vars DATABASE_URL="new-value"
```

### View Service Details
```bash
gcloud run services describe todo-backend --region us-central1
```

### Delete Services
```bash
gcloud run services delete todo-backend --region us-central1
gcloud run services delete todo-frontend --region us-central1
```

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| `gcloud: command not found` | Install Google Cloud SDK |
| `docker: command not found` | Install Docker |
| `Permission denied` | Run `gcloud auth login` |
| `Service fails to start` | Check logs: `gcloud run logs read SERVICE_NAME` |
| `Frontend can't reach backend` | Verify `NEXT_PUBLIC_BACKEND_URL` env var |
| `Database connection error` | Check connection string in `.env` |

---

## 💰 Cost Estimation

| Component | Cost |
|-----------|------|
| Cloud Run (1M requests) | ~$5 |
| Artifact Registry (1GB) | ~$0.10 |
| Cloud Build (100 builds) | ~$0.30 |
| **Total/month** | **~$5-10** |

---

## 📈 Resource Limits

| Resource | Value |
|----------|-------|
| Memory per service | 512Mi |
| CPU per service | 1 |
| Max instances | 10 |
| Request timeout | 3600s |
| Concurrent requests | 80 |

---

## 🔐 Security Checklist

- [ ] Never commit `.env` files
- [ ] Use Secret Manager for sensitive data
- [ ] Enable Cloud Armor for DDoS protection
- [ ] Set up IAM roles properly
- [ ] Enable Cloud Logging
- [ ] Rotate secrets regularly

---

## 📚 Documentation Links

- [Cloud Run Docs](https://cloud.google.com/run/docs)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)
- [Cloud Build](https://cloud.google.com/build/docs)
- [Terraform Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)

---

## 🎯 Deployment Methods

### 1. Automated Scripts (Fastest)
```bash
./deploy-all.sh  # or deploy-all.bat on Windows
```

### 2. Terraform (IaC)
```bash
cd terraform
terraform init
terraform apply
```

### 3. Manual gcloud
```bash
gcloud run deploy todo-backend --image IMAGE_URL ...
gcloud run deploy todo-frontend --image IMAGE_URL ...
```

### 4. Cloud Build (CI/CD)
```bash
gcloud builds submit --config=cloudbuild.yaml
```

---

## 🔄 Typical Workflow

1. **Setup** (One-time)
   ```bash
   ./setup-gcp.sh
   ```

2. **Deploy** (First time)
   ```bash
   ./deploy-all.sh
   ```

3. **Monitor**
   ```bash
   gcloud run logs read todo-backend --follow
   ```

4. **Update** (Code changes)
   ```bash
   ./deploy-all.sh  # Redeploy
   ```

5. **Cleanup** (When done)
   ```bash
   gcloud run services delete todo-backend
   gcloud run services delete todo-frontend
   ```

---

## 🆘 Getting Help

1. Check logs: `gcloud run logs read SERVICE_NAME --limit 100`
2. View service details: `gcloud run services describe SERVICE_NAME`
3. Read full guide: `DEPLOYMENT_GUIDE.md`
4. Check GCP documentation

---

## ⚡ Performance Tips

- Start with 512Mi memory, scale up if needed
- Use Cloud CDN for frontend caching
- Enable connection pooling for database
- Monitor metrics in Cloud Console
- Set up alerts for high error rates

---

## 🔄 Rollback

If something goes wrong:
```bash
# View previous revisions
gcloud run revisions list --service=todo-backend

# Route traffic to previous version
gcloud run services update-traffic todo-backend \
  --to-revisions=REVISION_NAME=100
```

---

## 📞 Quick Support

| Problem | Command |
|---------|---------|
| Check if services running | `gcloud run services list` |
| View recent errors | `gcloud run logs read SERVICE_NAME --limit 50` |
| Get service URL | `gcloud run services describe SERVICE_NAME --format 'value(status.url)'` |
| Update env var | `gcloud run services update SERVICE_NAME --update-env-vars KEY=VALUE` |
| View all revisions | `gcloud run revisions list --service=SERVICE_NAME` |

---

**Last Updated**: May 2026
**Quick Reference Version**: 1.0
