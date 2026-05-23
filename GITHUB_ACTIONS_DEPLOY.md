# 🚀 Deploy with GitHub Actions - Complete Setup Guide

Deploy your Todo Fullstack application to Google Cloud Run using GitHub Actions CI/CD pipeline.

## 📋 Overview

This guide will set up automated deployment where every push to the `main` branch automatically:
1. Builds Docker images for backend and frontend
2. Pushes images to Google Artifact Registry
3. Deploys services to Cloud Run
4. Sends deployment notifications

## ⏱️ Time Required

- **Setup:** 20-30 minutes (one-time)
- **Deployment:** Automatic on each push to main

## 🔧 Prerequisites

- GitHub repository with this code
- Google Cloud Project: `todo-497210`
- GitHub account with admin access to repository
- gcloud CLI installed locally

## 📝 Step-by-Step Setup

### Step 1: Create GCP Service Account

Run these commands in your terminal:

```bash
# Set variables
export GCP_PROJECT_ID="todo-497210"
export GCP_PROJECT_NUMBER=$(gcloud projects describe $GCP_PROJECT_ID --format='value(projectNumber)')

# Create service account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Service Account" \
  --project=$GCP_PROJECT_ID

# Get service account email
export SERVICE_ACCOUNT="github-actions@${GCP_PROJECT_ID}.iam.gserviceaccount.com"
echo "Service Account: $SERVICE_ACCOUNT"
```

### Step 2: Grant IAM Roles

```bash
# Cloud Run Admin
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/run.admin

# Artifact Registry Admin
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/artifactregistry.admin

# Service Account User
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/iam.serviceAccountUser

# Storage Admin
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/storage.admin
```

### Step 3: Set Up Workload Identity Federation

```bash
# Create workload identity pool
gcloud iam workload-identity-pools create "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --display-name="GitHub"

# Create workload identity provider
gcloud iam workload-identity-pools providers create-oidc "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --display-name="GitHub" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --workload-identity-pool="github"

# Get WIF provider resource name
export WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --workload-identity-pool="github" \
  --format="value(name)")

echo "WIF_PROVIDER: $WIF_PROVIDER"
```

### Step 4: Configure Service Account Impersonation

Replace `YOUR_GITHUB_USERNAME` and `YOUR_REPO_NAME` with your actual values:

```bash
# Set your GitHub details
export GITHUB_USERNAME="YOUR_GITHUB_USERNAME"
export GITHUB_REPO="HACKATHON_2"

# Allow GitHub to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \
  --project=$GCP_PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/${GITHUB_USERNAME}/${GITHUB_REPO}"
```

### Step 5: Create Artifact Registry Repository

```bash
# Create repository if it doesn't exist
gcloud artifacts repositories create todo-app \
  --repository-format=docker \
  --location=us-central1 \
  --description="Todo App Docker Images" \
  --project=$GCP_PROJECT_ID
```

### Step 6: Add GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these 6 secrets:

#### Secret 1: WIF_PROVIDER
```
Name: WIF_PROVIDER
Value: projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github
```
(Replace PROJECT_NUMBER with your actual project number)

#### Secret 2: WIF_SERVICE_ACCOUNT
```
Name: WIF_SERVICE_ACCOUNT
Value: github-actions@todo-497210.iam.gserviceaccount.com
```

#### Secret 3: DATABASE_URL
```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
```

#### Secret 4: DATABASE_URL_UNPOOLED
```
Name: DATABASE_URL_UNPOOLED
Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
```

#### Secret 5: AUTH_SECRET
```
Name: AUTH_SECRET
Value: dev-better-auth-secret-change-in-production
```

#### Secret 6: BETTER_AUTH_SECRET
```
Name: BETTER_AUTH_SECRET
Value: wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

### Step 7: Verify Workflow File

The workflow file is already in place at `.github/workflows/deploy-cloud-run.yml`

Check that it exists and contains the deployment configuration.

---

## 🚀 Deploy Your Application

### Method 1: Push to Main Branch (Automatic)

```bash
# Make sure you're on main branch
git checkout main

# Make a change (or just commit current state)
git add .
git commit -m "feat: trigger deployment"

# Push to main
git push origin main
```

The workflow will automatically start!

### Method 2: Manual Trigger (Optional)

You can also manually trigger the workflow:

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Deploy to Cloud Run** workflow
4. Click **Run workflow** button
5. Select branch and click **Run workflow**

---

## 📊 Workflow Execution

### What Happens When You Push

```
1. Push to main branch
   ↓
2. GitHub Actions triggered
   ├─ Setup job (prepare image names)
   ├─ Build backend image
   ├─ Build frontend image
   ├─ Deploy backend to Cloud Run
   ├─ Deploy frontend to Cloud Run
   └─ Send notification
   ↓
3. Services live on Cloud Run
```

### Workflow Jobs

| Job | Trigger | Duration |
|-----|---------|----------|
| setup | Always | 1 min |
| build-backend | Always | 5-10 min |
| build-frontend | Always | 5-10 min |
| deploy-backend | main push only | 2-3 min |
| deploy-frontend | main push only | 2-3 min |
| notify | Always | 1 min |

**Total time:** ~15-25 minutes

---

## 🔍 Monitor Deployment

### View Workflow Runs

1. Go to your GitHub repository
2. Click **Actions** tab
3. Select **Deploy to Cloud Run** workflow
4. View recent runs

### View Logs

Click on a workflow run to see detailed logs for each job.

### View Deployed Services

```bash
# List Cloud Run services
gcloud run services list --region us-central1

# View backend service
gcloud run services describe todo-backend --region us-central1

# View frontend service
gcloud run services describe todo-frontend --region us-central1
```

### View Application Logs

```bash
# Backend logs
gcloud run logs read todo-backend --region us-central1 --limit 50

# Frontend logs
gcloud run logs read todo-frontend --region us-central1 --limit 50

# Real-time logs
gcloud run logs read todo-backend --region us-central1 --follow
```

---

## ✅ Verify Deployment

### Check Services Are Running

```bash
gcloud run services list --region us-central1
```

You should see:
- `todo-backend` - Backend service URL
- `todo-frontend` - Frontend service URL

### Test Backend

```bash
# Get backend URL
BACKEND_URL=$(gcloud run services describe todo-backend --region us-central1 --format 'value(status.url)')

# Test health endpoint
curl $BACKEND_URL/health
```

### Test Frontend

1. Get frontend URL from Cloud Run console
2. Open in browser
3. Test application functionality

---

## 🆘 Troubleshooting

### Workflow fails with "Permission denied"

**Cause:** Service account doesn't have necessary permissions

**Solution:**
```bash
# Verify IAM roles
gcloud projects get-iam-policy todo-497210 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com"

# Re-grant roles if needed
gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/run.admin
```

### Workflow fails with "Authentication failed"

**Cause:** WIF configuration is incorrect

**Solution:**
1. Verify WIF_PROVIDER secret is correct
2. Verify WIF_SERVICE_ACCOUNT secret is correct
3. Check GitHub repository name matches in WIF configuration

### Docker image fails to push

**Cause:** Artifact Registry authentication issue

**Solution:**
```bash
# Verify Artifact Registry exists
gcloud artifacts repositories list --location=us-central1

# Verify service account has artifactregistry.admin role
gcloud projects get-iam-policy todo-497210 \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com AND bindings.role:roles/artifactregistry.admin"
```

### Cloud Run deployment fails

**Cause:** Environment variables or image issues

**Solution:**
```bash
# Check Cloud Run logs
gcloud run logs read todo-backend --region us-central1 --limit 100

# Verify environment variables
gcloud run services describe todo-backend --region us-central1 \
  --format='value(spec.template.spec.containers[0].env)'

# Check image exists in Artifact Registry
gcloud artifacts docker images list us-central1-docker.pkg.dev/todo-497210/todo-app
```

### Workflow doesn't trigger

**Cause:** Workflow file not in correct location or branch

**Solution:**
1. Verify `.github/workflows/deploy-cloud-run.yml` exists
2. Verify you're pushing to `main` branch
3. Check workflow file syntax is correct

---

## 📈 Advanced Configuration

### Deploy to Multiple Branches

Edit `.github/workflows/deploy-cloud-run.yml`:

```yaml
on:
  push:
    branches:
      - main
      - develop
      - staging
```

### Deploy to Multiple Regions

Add matrix strategy:

```yaml
strategy:
  matrix:
    region: [us-central1, europe-west1, asia-northeast1]
```

### Add Approval Step

Add environment protection:

```yaml
deploy-backend:
  environment:
    name: production
    url: https://console.cloud.google.com/run
```

### Add Testing

Add test job before deployment:

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run tests
      run: npm test
```

---

## 🔐 Security Best Practices

1. **Use Workload Identity Federation**
   - No long-lived credentials stored
   - Short-lived, scoped tokens
   - Secure OIDC-based authentication

2. **Minimal IAM Permissions**
   - Service account has only necessary roles
   - No overly permissive permissions
   - Principle of least privilege

3. **Secrets Management**
   - Secrets are encrypted in GitHub
   - Never commit secrets to repository
   - Rotate secrets regularly

4. **Audit Logging**
   - All deployments logged in Cloud Run
   - GitHub Actions logs available
   - GCP Cloud Audit Logs track changes

---

## 📞 Support

### Documentation
- `.github/workflows/README.md` - Workflow documentation
- `CI_CD_SETUP_GUIDE.md` - Comprehensive CI/CD guide
- `GITHUB_CICD_SUMMARY.md` - GitHub Actions summary

### Official Resources
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Cloud Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)

### Commands for Help

```bash
# View workflow runs
gh run list --repo YOUR_USERNAME/HACKATHON_2

# View specific run
gh run view RUN_ID --repo YOUR_USERNAME/HACKATHON_2

# View logs
gh run view RUN_ID --log --repo YOUR_USERNAME/HACKATHON_2
```

---

## ✅ Deployment Checklist

- [ ] Service account created
- [ ] IAM roles granted
- [ ] Workload Identity Federation configured
- [ ] GitHub secrets added (all 6)
- [ ] Artifact Registry repository created
- [ ] Workflow file in `.github/workflows/`
- [ ] Code pushed to main branch
- [ ] Workflow runs successfully
- [ ] Services deployed to Cloud Run
- [ ] Application accessible
- [ ] Logs verified for errors

---

## 🎉 You're All Set!

Your GitHub Actions CI/CD pipeline is now configured. Every push to main will automatically deploy your application!

### Next Steps

1. Push code to main branch
2. Monitor workflow in GitHub Actions
3. Verify services in Cloud Run console
4. Test application functionality

---

**Last Updated:** May 2026
**Version:** 1.0
**Status:** Production Ready ✅

**Happy Deploying! 🚀**
