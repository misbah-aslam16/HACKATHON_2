# ⚡ Quick GitHub Actions Setup (5 Minutes)

Fast-track setup to deploy using GitHub Actions. Copy and paste commands.

## 🚀 One-Command Setup

### Step 1: Set Your GitHub Username

```bash
export GITHUB_USERNAME="your-github-username"
export GITHUB_REPO="HACKATHON_2"
```

### Step 2: Run All Setup Commands

Copy and paste this entire block:

```bash
#!/bin/bash
set -e

# Variables
GCP_PROJECT_ID="todo-497210"
GCP_PROJECT_NUMBER=$(gcloud projects describe $GCP_PROJECT_ID --format='value(projectNumber)')
SERVICE_ACCOUNT="github-actions@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

echo "🔧 Setting up GitHub Actions CI/CD..."
echo ""

# Create service account
echo "1️⃣  Creating service account..."
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Service Account" \
  --project=$GCP_PROJECT_ID 2>/dev/null || echo "   Service account already exists"

# Grant IAM roles
echo "2️⃣  Granting IAM roles..."
for role in roles/run.admin roles/artifactregistry.admin roles/iam.serviceAccountUser roles/storage.admin; do
  gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
    --member=serviceAccount:$SERVICE_ACCOUNT \
    --role=$role \
    --quiet 2>/dev/null || true
done

# Create Workload Identity Pool
echo "3️⃣  Creating Workload Identity Pool..."
gcloud iam workload-identity-pools create "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --display-name="GitHub" 2>/dev/null || echo "   Pool already exists"

# Create Workload Identity Provider
echo "4️⃣  Creating Workload Identity Provider..."
gcloud iam workload-identity-pools providers create-oidc "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --display-name="GitHub" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --workload-identity-pool="github" 2>/dev/null || echo "   Provider already exists"

# Get WIF provider
echo "5️⃣  Getting Workload Identity Provider..."
WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe "github" \
  --project=$GCP_PROJECT_ID \
  --location="global" \
  --workload-identity-pool="github" \
  --format="value(name)")

# Configure service account impersonation
echo "6️⃣  Configuring service account impersonation..."
gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \
  --project=$GCP_PROJECT_ID \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/${GITHUB_USERNAME}/${GITHUB_REPO}" \
  --quiet 2>/dev/null || echo "   Already configured"

# Create Artifact Registry
echo "7️⃣  Creating Artifact Registry repository..."
gcloud artifacts repositories create todo-app \
  --repository-format=docker \
  --location=us-central1 \
  --description="Todo App Docker Images" \
  --project=$GCP_PROJECT_ID 2>/dev/null || echo "   Repository already exists"

echo ""
echo "✅ Setup Complete!"
echo ""
echo "📋 GitHub Secrets to Add:"
echo ""
echo "1. WIF_PROVIDER"
echo "   Value: $WIF_PROVIDER"
echo ""
echo "2. WIF_SERVICE_ACCOUNT"
echo "   Value: $SERVICE_ACCOUNT"
echo ""
echo "3. DATABASE_URL"
echo "   Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require"
echo ""
echo "4. DATABASE_URL_UNPOOLED"
echo "   Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require"
echo ""
echo "5. AUTH_SECRET"
echo "   Value: dev-better-auth-secret-change-in-production"
echo ""
echo "6. BETTER_AUTH_SECRET"
echo "   Value: wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc="
echo ""
echo "🔗 Add secrets at: https://github.com/$GITHUB_USERNAME/$GITHUB_REPO/settings/secrets/actions"
echo ""
echo "🚀 Next: Push to main branch to trigger deployment!"
```

## 📋 Manual Steps (If Script Doesn't Work)

### 1. Create Service Account
```bash
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions Service Account" \
  --project=todo-497210
```

### 2. Grant Roles
```bash
gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/run.admin

gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/artifactregistry.admin

gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/storage.admin
```

### 3. Create Workload Identity Pool
```bash
gcloud iam workload-identity-pools create "github" \
  --project=todo-497210 \
  --location="global" \
  --display-name="GitHub"
```

### 4. Create Workload Identity Provider
```bash
gcloud iam workload-identity-pools providers create-oidc "github" \
  --project=todo-497210 \
  --location="global" \
  --display-name="GitHub" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --workload-identity-pool="github"
```

### 5. Get WIF Provider
```bash
gcloud iam workload-identity-pools providers describe "github" \
  --project=todo-497210 \
  --location="global" \
  --workload-identity-pool="github" \
  --format="value(name)"
```

### 6. Configure Impersonation
```bash
# Replace YOUR_GITHUB_USERNAME and YOUR_REPO_NAME
gcloud iam service-accounts add-iam-policy-binding \
  github-actions@todo-497210.iam.gserviceaccount.com \
  --project=todo-497210 \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/attribute.repository/YOUR_GITHUB_USERNAME/YOUR_REPO_NAME"
```

### 7. Create Artifact Registry
```bash
gcloud artifacts repositories create todo-app \
  --repository-format=docker \
  --location=us-central1 \
  --description="Todo App Docker Images" \
  --project=todo-497210
```

## 🔐 Add GitHub Secrets

1. Go to: `https://github.com/YOUR_USERNAME/HACKATHON_2/settings/secrets/actions`
2. Click **New repository secret**
3. Add these 6 secrets:

| Name | Value |
|------|-------|
| WIF_PROVIDER | `projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github` |
| WIF_SERVICE_ACCOUNT | `github-actions@todo-497210.iam.gserviceaccount.com` |
| DATABASE_URL | `postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require` |
| DATABASE_URL_UNPOOLED | `postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require` |
| AUTH_SECRET | `dev-better-auth-secret-change-in-production` |
| BETTER_AUTH_SECRET | `wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=` |

## 🚀 Deploy

### Push to Main Branch
```bash
git add .
git commit -m "feat: trigger deployment"
git push origin main
```

### Monitor Deployment
1. Go to: `https://github.com/YOUR_USERNAME/HACKATHON_2/actions`
2. Watch the workflow run
3. Check Cloud Run console for deployed services

## ✅ Verify

```bash
# View services
gcloud run services list --region us-central1

# View logs
gcloud run logs read todo-backend --region us-central1 --follow
```

## 🎉 Done!

Your application is now deployed via GitHub Actions!

---

**Time to deploy:** ~15-25 minutes
**Status:** ✅ Production Ready
