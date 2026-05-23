#!/bin/bash

# CI/CD Setup Script for GitHub Actions + Cloud Run
# This script automates the setup of Workload Identity Federation and IAM roles

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== GitHub Actions + Cloud Run CI/CD Setup ===${NC}"
echo ""

# Check if gcloud is installed
if ! command -v gcloud &> /dev/null; then
    echo -e "${RED}Error: gcloud CLI is not installed${NC}"
    echo "Install from: https://cloud.google.com/sdk/docs/install"
    exit 1
fi

# Get configuration
read -p "Enter GCP Project ID (default: todo-497210): " GCP_PROJECT_ID
GCP_PROJECT_ID=${GCP_PROJECT_ID:-todo-497210}

read -p "Enter GitHub username: " GITHUB_USERNAME
read -p "Enter GitHub repository name (default: HACKATHON_2): " GITHUB_REPO
GITHUB_REPO=${GITHUB_REPO:-HACKATHON_2}

echo ""
echo -e "${YELLOW}Configuration:${NC}"
echo "GCP Project ID: $GCP_PROJECT_ID"
echo "GitHub Username: $GITHUB_USERNAME"
echo "GitHub Repository: $GITHUB_REPO"
echo ""

# Set project
echo -e "${YELLOW}Setting GCP project...${NC}"
gcloud config set project $GCP_PROJECT_ID

# Get project number
GCP_PROJECT_NUMBER=$(gcloud projects describe $GCP_PROJECT_ID --format='value(projectNumber)')
echo "Project Number: $GCP_PROJECT_NUMBER"

# Create service account
echo -e "${YELLOW}Creating service account...${NC}"
SERVICE_ACCOUNT="github-actions@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

if gcloud iam service-accounts describe $SERVICE_ACCOUNT &> /dev/null; then
    echo -e "${GREEN}Service account already exists${NC}"
else
    gcloud iam service-accounts create github-actions \
        --display-name="GitHub Actions Service Account"
    echo -e "${GREEN}Service account created${NC}"
fi

# Grant IAM roles
echo -e "${YELLOW}Granting IAM roles...${NC}"

ROLES=(
    "roles/run.admin"
    "roles/artifactregistry.admin"
    "roles/iam.serviceAccountUser"
    "roles/storage.admin"
)

for role in "${ROLES[@]}"; do
    echo "Granting $role..."
    gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
        --member=serviceAccount:$SERVICE_ACCOUNT \
        --role=$role \
        --quiet
done

echo -e "${GREEN}IAM roles granted${NC}"

# Create Workload Identity Pool
echo -e "${YELLOW}Creating Workload Identity Pool...${NC}"

if gcloud iam workload-identity-pools describe "github" \
    --project=$GCP_PROJECT_ID \
    --location="global" &> /dev/null; then
    echo -e "${GREEN}Workload Identity Pool already exists${NC}"
else
    gcloud iam workload-identity-pools create "github" \
        --project=$GCP_PROJECT_ID \
        --location="global" \
        --display-name="GitHub"
    echo -e "${GREEN}Workload Identity Pool created${NC}"
fi

# Create Workload Identity Provider
echo -e "${YELLOW}Creating Workload Identity Provider...${NC}"

if gcloud iam workload-identity-pools providers describe "github" \
    --project=$GCP_PROJECT_ID \
    --location="global" \
    --workload-identity-pool="github" &> /dev/null; then
    echo -e "${GREEN}Workload Identity Provider already exists${NC}"
else
    gcloud iam workload-identity-pools providers create-oidc "github" \
        --project=$GCP_PROJECT_ID \
        --location="global" \
        --display-name="GitHub" \
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" \
        --issuer-uri="https://token.actions.githubusercontent.com" \
        --workload-identity-pool="github"
    echo -e "${GREEN}Workload Identity Provider created${NC}"
fi

# Get WIF provider resource name
WIF_PROVIDER=$(gcloud iam workload-identity-pools providers describe "github" \
    --project=$GCP_PROJECT_ID \
    --location="global" \
    --workload-identity-pool="github" \
    --format="value(name)")

echo -e "${GREEN}WIF Provider: $WIF_PROVIDER${NC}"

# Configure service account impersonation
echo -e "${YELLOW}Configuring service account impersonation...${NC}"

gcloud iam service-accounts add-iam-policy-binding $SERVICE_ACCOUNT \
    --project=$GCP_PROJECT_ID \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/${GCP_PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/attribute.repository/${GITHUB_USERNAME}/${GITHUB_REPO}" \
    --quiet

echo -e "${GREEN}Service account impersonation configured${NC}"

# Create Artifact Registry repository
echo -e "${YELLOW}Creating Artifact Registry repository...${NC}"

if gcloud artifacts repositories describe todo-app \
    --location=us-central1 &> /dev/null; then
    echo -e "${GREEN}Artifact Registry repository already exists${NC}"
else
    gcloud artifacts repositories create todo-app \
        --repository-format=docker \
        --location=us-central1 \
        --description="Todo App Docker Images"
    echo -e "${GREEN}Artifact Registry repository created${NC}"
fi

# Create configuration file
echo -e "${YELLOW}Creating configuration file...${NC}"

cat > .github/workflows/.env.cicd << EOF
# CI/CD Configuration
GCP_PROJECT_ID=$GCP_PROJECT_ID
GCP_PROJECT_NUMBER=$GCP_PROJECT_NUMBER
GCP_REGION=us-central1
ARTIFACT_REGISTRY_REPO=todo-app
ARTIFACT_REGISTRY_REGION=us-central1
BACKEND_SERVICE_NAME=todo-backend
FRONTEND_SERVICE_NAME=todo-frontend
SERVICE_ACCOUNT=$SERVICE_ACCOUNT
WIF_PROVIDER=$WIF_PROVIDER
GITHUB_USERNAME=$GITHUB_USERNAME
GITHUB_REPO=$GITHUB_REPO
EOF

echo -e "${GREEN}Configuration file created${NC}"

# Display summary
echo ""
echo -e "${GREEN}=== Setup Complete ===${NC}"
echo ""
echo -e "${YELLOW}GitHub Secrets to Add:${NC}"
echo ""
echo "1. WIF_PROVIDER"
echo "   Value: $WIF_PROVIDER"
echo ""
echo "2. WIF_SERVICE_ACCOUNT"
echo "   Value: $SERVICE_ACCOUNT"
echo ""
echo "3. DATABASE_URL"
echo "   Value: (from your .env file)"
echo ""
echo "4. DATABASE_URL_UNPOOLED"
echo "   Value: (from your .env file)"
echo ""
echo "5. AUTH_SECRET"
echo "   Value: (from your .env file)"
echo ""
echo "6. BETTER_AUTH_SECRET"
echo "   Value: (from your .env file)"
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Go to GitHub repository Settings → Secrets and variables → Actions"
echo "2. Add the secrets listed above"
echo "3. Push code to main branch"
echo "4. Monitor workflow in GitHub Actions"
echo "5. Verify deployment in Cloud Run console"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo ""
echo "View workflow runs:"
echo "  gh run list --repo $GITHUB_USERNAME/$GITHUB_REPO"
echo ""
echo "View Cloud Run services:"
echo "  gcloud run services list --region us-central1"
echo ""
echo "View logs:"
echo "  gcloud run logs read todo-backend --region us-central1 --follow"
echo ""
