@echo off
REM CI/CD Setup Script for GitHub Actions + Cloud Run (Windows)

setlocal enabledelayedexpansion

echo.
echo === GitHub Actions + Cloud Run CI/CD Setup ===
echo.

REM Check if gcloud is installed
where gcloud >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: gcloud CLI is not installed
    echo Install from: https://cloud.google.com/sdk/docs/install
    exit /b 1
)

REM Get configuration
set /p GCP_PROJECT_ID="Enter GCP Project ID (default: todo-497210): "
if "!GCP_PROJECT_ID!"=="" set GCP_PROJECT_ID=todo-497210

set /p GITHUB_USERNAME="Enter GitHub username: "
set /p GITHUB_REPO="Enter GitHub repository name (default: HACKATHON_2): "
if "!GITHUB_REPO!"=="" set GITHUB_REPO=HACKATHON_2

echo.
echo Configuration:
echo GCP Project ID: !GCP_PROJECT_ID!
echo GitHub Username: !GITHUB_USERNAME!
echo GitHub Repository: !GITHUB_REPO!
echo.

REM Set project
echo Setting GCP project...
call gcloud config set project !GCP_PROJECT_ID!

REM Get project number
for /f %%i in ('gcloud projects describe !GCP_PROJECT_ID! --format "value(projectNumber)"') do set GCP_PROJECT_NUMBER=%%i
echo Project Number: !GCP_PROJECT_NUMBER!

REM Create service account
echo Creating service account...
set SERVICE_ACCOUNT=github-actions@!GCP_PROJECT_ID!.iam.gserviceaccount.com

call gcloud iam service-accounts describe !SERVICE_ACCOUNT! >nul 2>&1
if %errorlevel% equ 0 (
    echo Service account already exists
) else (
    call gcloud iam service-accounts create github-actions ^
        --display-name="GitHub Actions Service Account"
    echo Service account created
)

REM Grant IAM roles
echo Granting IAM roles...

call gcloud projects add-iam-policy-binding !GCP_PROJECT_ID! ^
    --member=serviceAccount:!SERVICE_ACCOUNT! ^
    --role=roles/run.admin ^
    --quiet

call gcloud projects add-iam-policy-binding !GCP_PROJECT_ID! ^
    --member=serviceAccount:!SERVICE_ACCOUNT! ^
    --role=roles/artifactregistry.admin ^
    --quiet

call gcloud projects add-iam-policy-binding !GCP_PROJECT_ID! ^
    --member=serviceAccount:!SERVICE_ACCOUNT! ^
    --role=roles/iam.serviceAccountUser ^
    --quiet

call gcloud projects add-iam-policy-binding !GCP_PROJECT_ID! ^
    --member=serviceAccount:!SERVICE_ACCOUNT! ^
    --role=roles/storage.admin ^
    --quiet

echo IAM roles granted

REM Create Workload Identity Pool
echo Creating Workload Identity Pool...

call gcloud iam workload-identity-pools describe "github" ^
    --project=!GCP_PROJECT_ID! ^
    --location="global" >nul 2>&1

if %errorlevel% equ 0 (
    echo Workload Identity Pool already exists
) else (
    call gcloud iam workload-identity-pools create "github" ^
        --project=!GCP_PROJECT_ID! ^
        --location="global" ^
        --display-name="GitHub"
    echo Workload Identity Pool created
)

REM Create Workload Identity Provider
echo Creating Workload Identity Provider...

call gcloud iam workload-identity-pools providers describe "github" ^
    --project=!GCP_PROJECT_ID! ^
    --location="global" ^
    --workload-identity-pool="github" >nul 2>&1

if %errorlevel% equ 0 (
    echo Workload Identity Provider already exists
) else (
    call gcloud iam workload-identity-pools providers create-oidc "github" ^
        --project=!GCP_PROJECT_ID! ^
        --location="global" ^
        --display-name="GitHub" ^
        --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository,attribute.repository_owner=assertion.repository_owner" ^
        --issuer-uri="https://token.actions.githubusercontent.com" ^
        --workload-identity-pool="github"
    echo Workload Identity Provider created
)

REM Get WIF provider resource name
for /f %%i in ('gcloud iam workload-identity-pools providers describe "github" --project=!GCP_PROJECT_ID! --location="global" --workload-identity-pool="github" --format "value(name)"') do set WIF_PROVIDER=%%i

echo WIF Provider: !WIF_PROVIDER!

REM Configure service account impersonation
echo Configuring service account impersonation...

call gcloud iam service-accounts add-iam-policy-binding !SERVICE_ACCOUNT! ^
    --project=!GCP_PROJECT_ID! ^
    --role="roles/iam.workloadIdentityUser" ^
    --member="principalSet://iam.googleapis.com/projects/!GCP_PROJECT_NUMBER!/locations/global/workloadIdentityPools/github/attribute.repository/!GITHUB_USERNAME!/!GITHUB_REPO!" ^
    --quiet

echo Service account impersonation configured

REM Create Artifact Registry repository
echo Creating Artifact Registry repository...

call gcloud artifacts repositories describe todo-app ^
    --location=us-central1 >nul 2>&1

if %errorlevel% equ 0 (
    echo Artifact Registry repository already exists
) else (
    call gcloud artifacts repositories create todo-app ^
        --repository-format=docker ^
        --location=us-central1 ^
        --description="Todo App Docker Images"
    echo Artifact Registry repository created
)

REM Create configuration file
echo Creating configuration file...

if not exist .github\workflows mkdir .github\workflows

(
    echo # CI/CD Configuration
    echo GCP_PROJECT_ID=!GCP_PROJECT_ID!
    echo GCP_PROJECT_NUMBER=!GCP_PROJECT_NUMBER!
    echo GCP_REGION=us-central1
    echo ARTIFACT_REGISTRY_REPO=todo-app
    echo ARTIFACT_REGISTRY_REGION=us-central1
    echo BACKEND_SERVICE_NAME=todo-backend
    echo FRONTEND_SERVICE_NAME=todo-frontend
    echo SERVICE_ACCOUNT=!SERVICE_ACCOUNT!
    echo WIF_PROVIDER=!WIF_PROVIDER!
    echo GITHUB_USERNAME=!GITHUB_USERNAME!
    echo GITHUB_REPO=!GITHUB_REPO!
) > .github\workflows\.env.cicd

echo Configuration file created

REM Display summary
echo.
echo === Setup Complete ===
echo.
echo GitHub Secrets to Add:
echo.
echo 1. WIF_PROVIDER
echo    Value: !WIF_PROVIDER!
echo.
echo 2. WIF_SERVICE_ACCOUNT
echo    Value: !SERVICE_ACCOUNT!
echo.
echo 3. DATABASE_URL
echo    Value: (from your .env file^)
echo.
echo 4. DATABASE_URL_UNPOOLED
echo    Value: (from your .env file^)
echo.
echo 5. AUTH_SECRET
echo    Value: (from your .env file^)
echo.
echo 6. BETTER_AUTH_SECRET
echo    Value: (from your .env file^)
echo.
echo Next Steps:
echo 1. Go to GitHub repository Settings ^> Secrets and variables ^> Actions
echo 2. Add the secrets listed above
echo 3. Push code to main branch
echo 4. Monitor workflow in GitHub Actions
echo 5. Verify deployment in Cloud Run console
echo.
echo Useful Commands:
echo.
echo View workflow runs:
echo   gh run list --repo !GITHUB_USERNAME!/!GITHUB_REPO!
echo.
echo View Cloud Run services:
echo   gcloud run services list --region us-central1
echo.
echo View logs:
echo   gcloud run logs read todo-backend --region us-central1 --follow
echo.
pause
