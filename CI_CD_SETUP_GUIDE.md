# 🚀 CI/CD Pipeline Setup Guide - GitHub Actions + Cloud Run

Complete guide to set up automated deployment from GitHub to Google Cloud Run.

## 📋 Overview

This CI/CD pipeline automatically:
- Builds Docker images on every push
- Pushes images to Google Artifact Registry
- Deploys to Cloud Run on main branch
- Provides deployment notifications

## 🎯 Architecture

```
GitHub Repository
    │
    ├─ Push to main
    │   │
    │   ▼
    ├─ GitHub Actions Workflow
    │   ├─ Build Backend Image
    │   ├─ Build Frontend Image
    │   ├─ Push to Artifact Registry
    │   │
    │   ├─ Deploy Backend to Cloud Run
    │   ├─ Deploy Frontend to Cloud Run
    │   │
    │   └─ Send Notification
    │
    └─ Cloud Run Services
        ├─ todo-backend
        └─ todo-frontend
```

## 🔧 Prerequisites

- GitHub repository with this code
- Google Cloud Project (todo-497210)
- gcloud CLI installed locally
- Appropriate permissions in GCP

## 📝 Step-by-Step Setup

### Step 1: Create GCP Service Account

```bash
# Set project
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

# Storage Admin (for Artifact Registry)
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

```bash
# Get your GitHub username and repository name
export GITHUB_USERNAME="your-github-username"
export GITHUB_REPO="HACKATHON_2"

# Allow GitHub to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \
  --project=$GCP_PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/${GITHUB_USERNAME}/${GITHUB_REPO}"
```

### Step 5: Add GitHub Secrets

1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add these secrets:

**Secret 1: WIF_PROVIDER**
```
Name: WIF_PROVIDER
Value: projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github
```

**Secret 2: WIF_SERVICE_ACCOUNT**
```
Name: WIF_SERVICE_ACCOUNT
Value: github-actions@todo-497210.iam.gserviceaccount.com
```

**Secret 3: DATABASE_URL**
```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Secret 4: DATABASE_URL_UNPOOLED**
```
Name: DATABASE_URL_UNPOOLED
Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
```

**Secret 5: AUTH_SECRET**
```
Name: AUTH_SECRET
Value: dev-better-auth-secret-change-in-production
```

**Secret 6: BETTER_AUTH_SECRET**
```
Name: BETTER_AUTH_SECRET
Value: wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

### Step 6: Verify Artifact Registry

```bash
# Create Artifact Registry repository if it doesn't exist
gcloud artifacts repositories create todo-app \
  --repository-format=docker \
  --location=us-central1 \
  --description="Todo App Docker Images" \
  --project=$GCP_PROJECT_ID
```

### Step 7: Test the Pipeline

```bash
# Make a small change and push to main
git add .
git commit -m "test: trigger CI/CD pipeline"
git push origin main
```

Monitor the workflow:
1. Go to your GitHub repository
2. Click **Actions** tab
3. Watch the workflow run
4. Check Cloud Run console for deployed services

## 📊 Workflow Details

### Triggers

| Event | Branch | Action |
|-------|--------|--------|
| Push | main | Build + Deploy |
| Push | develop | Build only |
| Pull Request | main/develop | Build only |

### Jobs

**1. setup**
- Prepares image names with commit SHA
- Outputs image names for other jobs

**2. build-backend**
- Authenticates to GCP
- Builds backend Docker image
- Pushes to Artifact Registry

**3. build-frontend**
- Authenticates to GCP
- Builds frontend Docker image
- Pushes to Artifact Registry

**4. deploy-backend**
- Runs only on main branch push
- Deploys backend to Cloud Run
- Sets environment variables

**5. deploy-frontend**
- Runs only on main branch push
- Deploys frontend to Cloud Run
- Gets backend URL and sets it as env var

**6. notify**
- Creates deployment summary
- Posts to GitHub Actions summary

## 🔍 Monitoring

### View Workflow Runs

```bash
# List recent workflow runs
gh run list --repo YOUR_USERNAME/HACKATHON_2

# View specific run details
gh run view RUN_ID --repo YOUR_USERNAME/HACKATHON_2

# View run logs
gh run view RUN_ID --log --repo YOUR_USERNAME/HACKATHON_2
```

### View Cloud Run Deployments

```bash
# List services
gcloud run services list --region us-central1

# View service details
gcloud run services describe todo-backend --region us-central1

# View recent revisions
gcloud run revisions list --service=todo-backend --region us-central1

# View logs
gcloud run logs read todo-backend --region us-central1 --limit 50
```

## 🆘 Troubleshooting

### Workflow fails with "Permission denied"

**Cause:** Service account doesn't have necessary permissions

**Solution:**
```bash
# Verify IAM roles
gcloud projects get-iam-policy $GCP_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT"

# Re-grant roles if needed
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:$SERVICE_ACCOUNT \
  --role=roles/run.admin
```

### Workflow fails with "Authentication failed"

**Cause:** WIF configuration is incorrect

**Solution:**
```bash
# Verify WIF provider
gcloud iam workload-identity-pools providers describe "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --workload-identity-pool="github"

# Verify service account impersonation
gcloud iam service-accounts get-iam-policy $SERVICE_ACCOUNT \
  --project=$GCP_PROJECT_ID
```

### Docker image fails to push

**Cause:** Artifact Registry authentication issue

**Solution:**
```bash
# Verify Artifact Registry exists
gcloud artifacts repositories list --location=us-central1

# Verify service account has artifactregistry.admin role
gcloud projects get-iam-policy $GCP_PROJECT_ID \
  --flatten="bindings[].members" \
  --filter="bindings.members:serviceAccount:$SERVICE_ACCOUNT AND bindings.role:roles/artifactregistry.admin"
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
gcloud artifacts docker images list us-central1-docker.pkg.dev/$GCP_PROJECT_ID/todo-app
```

## 🔐 Security Best Practices

1. **Use Workload Identity Federation**
   - No long-lived credentials stored in GitHub
   - Credentials are short-lived and scoped

2. **Minimal IAM Permissions**
   - Service account has only necessary roles
   - No overly permissive roles like Editor

3. **Secrets Management**
   - Secrets are encrypted in GitHub
   - Never commit secrets to repository
   - Rotate secrets regularly

4. **Audit Logging**
   - All deployments are logged in Cloud Run
   - GitHub Actions logs are available
   - GCP Cloud Audit Logs track all changes

## 📈 Advanced Configuration

### Deploy to Multiple Regions

```yaml
strategy:
  matrix:
    region: [us-central1, europe-west1, asia-northeast1]
```

### Deploy to Multiple Environments

```yaml
jobs:
  deploy-staging:
    if: github.ref == 'refs/heads/develop'
    # Deploy to staging environment
  
  deploy-production:
    if: github.ref == 'refs/heads/main'
    # Deploy to production environment
```

### Add Approval Step

```yaml
deploy-production:
  environment:
    name: production
    url: https://todo-frontend-xxxxx.run.app
  # Requires manual approval before deployment
```

### Add Testing

```yaml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Run tests
      run: npm test
```

## 📞 Support

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Cloud Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
- [Artifact Registry Documentation](https://cloud.google.com/artifact-registry/docs)

## ✅ Deployment Checklist

- [ ] Service account created
- [ ] IAM roles granted
- [ ] Workload Identity Federation configured
- [ ] GitHub secrets added
- [ ] Artifact Registry repository created
- [ ] Workflow file in `.github/workflows/`
- [ ] Test push to main branch
- [ ] Verify workflow runs successfully
- [ ] Check Cloud Run services are deployed
- [ ] Test application functionality

## 🎉 You're All Set!

Your CI/CD pipeline is now configured. Every push to main will automatically:
1. Build Docker images
2. Push to Artifact Registry
3. Deploy to Cloud Run
4. Provide deployment summary

**Next Steps:**
1. Push code to main branch
2. Monitor workflow in GitHub Actions
3. Verify services in Cloud Run console
4. Test application

---

**Last Updated:** May 2026
**Version:** 1.0
**Status:** Production Ready ✅
