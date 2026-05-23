# GitHub Actions CI/CD Pipeline

Automated deployment to Google Cloud Run on every push to main branch.

## Workflows

### deploy-cloud-run.yml
Builds and deploys both backend and frontend services to Cloud Run.

**Triggers:**
- Push to `main` branch (deploys)
- Push to `develop` branch (builds only)
- Pull requests to `main` or `develop` (builds only)

**Jobs:**
1. **setup** - Prepare image names
2. **build-backend** - Build backend Docker image
3. **build-frontend** - Build frontend Docker image
4. **deploy-backend** - Deploy backend to Cloud Run (main only)
5. **deploy-frontend** - Deploy frontend to Cloud Run (main only)
6. **notify** - Send deployment summary

## Setup Instructions

### 1. Create Service Account

```bash
# Create service account
gcloud iam service-accounts create github-actions \
  --display-name="GitHub Actions" \
  --project=todo-497210

# Grant necessary roles
gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/run.admin

gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/artifactregistry.admin

gcloud projects add-iam-policy-binding todo-497210 \
  --member=serviceAccount:github-actions@todo-497210.iam.gserviceaccount.com \
  --role=roles/iam.serviceAccountUser
```

### 2. Set Up Workload Identity Federation

```bash
# Create workload identity pool
gcloud iam workload-identity-pools create "github" \
  --project="todo-497210" \
  --location="global" \
  --display-name="GitHub"

# Create workload identity provider
gcloud iam workload-identity-pools providers create-oidc "github" \
  --project="todo-497210" \
  --location="global" \
  --display-name="GitHub" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --workload-identity-pool="github"

# Get the workload identity provider resource name
WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe "github" \
  --project="todo-497210" \
  --location="global" \
  --workload-identity-pool="github" \
  --format="value(name)")

echo "WIF_PROVIDER: $WIF_PROVIDER"
```

### 3. Create Service Account Impersonation

```bash
# Allow GitHub to impersonate the service account
gcloud iam service-accounts add-iam-policy-binding \
  github-actions@todo-497210.iam.gserviceaccount.com \
  --project="todo-497210" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/attribute.repository/YOUR_GITHUB_USERNAME/HACKATHON_2"
```

### 4. Add GitHub Secrets

Go to your GitHub repository settings and add these secrets:

**Required Secrets:**
- `WIF_PROVIDER` - Workload Identity Provider resource name
- `WIF_SERVICE_ACCOUNT` - Service account email (github-actions@todo-497210.iam.gserviceaccount.com)
- `DATABASE_URL` - Neon database pooled connection string
- `DATABASE_URL_UNPOOLED` - Neon database unpooled connection string
- `AUTH_SECRET` - Authentication secret
- `BETTER_AUTH_SECRET` - Better Auth secret

**Example:**
```
WIF_PROVIDER=projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github
WIF_SERVICE_ACCOUNT=github-actions@todo-497210.iam.gserviceaccount.com
DATABASE_URL=postgresql://...
DATABASE_URL_UNPOOLED=postgresql://...
AUTH_SECRET=your-secret
BETTER_AUTH_SECRET=your-secret
```

### 5. Push to Main Branch

```bash
git push origin main
```

The workflow will automatically:
1. Build backend and frontend Docker images
2. Push to Artifact Registry
3. Deploy to Cloud Run
4. Provide deployment summary

## Monitoring

### View Workflow Runs
- Go to your GitHub repository
- Click "Actions" tab
- View workflow runs and logs

### View Deployments
- Go to Google Cloud Console
- Navigate to Cloud Run
- Check service revisions and traffic

## Troubleshooting

### Workflow fails with authentication error
- Verify WIF_PROVIDER and WIF_SERVICE_ACCOUNT secrets are correct
- Check service account has necessary IAM roles
- Verify workload identity federation is configured

### Deployment fails
- Check Cloud Run logs: `gcloud run logs read SERVICE_NAME`
- Verify environment variables are set correctly
- Ensure database connection string is valid

### Images not pushed to Artifact Registry
- Verify service account has artifactregistry.admin role
- Check Docker authentication is configured
- Verify Artifact Registry repository exists

## Manual Deployment

If you need to deploy manually:

```bash
cd infra/gcp
./deploy-all.sh  # Linux/Mac
# or
deploy-all.bat   # Windows
```

## Cost Optimization

- Builds only run on push/PR (not on every commit)
- Deployments only run on main branch
- Images are tagged with commit SHA for traceability
- Old images can be cleaned up manually

## Security

- Uses Workload Identity Federation (no long-lived credentials)
- Secrets are encrypted in GitHub
- Service account has minimal required permissions
- Deployments are audited in Cloud Run

## Next Steps

1. Set up Workload Identity Federation
2. Add GitHub secrets
3. Push to main branch
4. Monitor workflow execution
5. Verify services are deployed

## Support

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Google Cloud Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Cloud Run Documentation](https://cloud.google.com/run/docs)
