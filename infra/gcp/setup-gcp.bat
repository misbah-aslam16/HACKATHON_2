@echo off
REM Google Cloud Run Setup Script for Windows
REM This script initializes GCP resources for Todo App deployment

setlocal enabledelayedexpansion

echo.
echo === Google Cloud Run Setup ===
echo.

REM Check if gcloud is installed
where gcloud >nul 2>nul
if %errorlevel% neq 0 (
    echo Error: gcloud CLI is not installed
    echo Install from: https://cloud.google.com/sdk/docs/install
    exit /b 1
)

REM Get project ID
set /p GCP_PROJECT_ID="Enter your GCP Project ID: "
set /p GCP_REGION="Enter GCP Region (default: us-central1): "
if "!GCP_REGION!"=="" set GCP_REGION=us-central1

set /p ARTIFACT_REGISTRY_REPO="Enter Artifact Registry Repository name (default: todo-app): "
if "!ARTIFACT_REGISTRY_REPO!"=="" set ARTIFACT_REGISTRY_REPO=todo-app

set ARTIFACT_REGISTRY_REGION=!GCP_REGION!

echo.
echo Configuration:
echo Project ID: !GCP_PROJECT_ID!
echo Region: !GCP_REGION!
echo Artifact Registry: !ARTIFACT_REGISTRY_REPO!
echo.

REM Set project
echo Setting GCP project...
call gcloud config set project !GCP_PROJECT_ID!

REM Authenticate
echo Authenticating with GCP...
call gcloud auth login

REM Enable required APIs
echo Enabling required APIs...
call gcloud services enable ^
    run.googleapis.com ^
    artifactregistry.googleapis.com ^
    cloudbuild.googleapis.com ^
    containerregistry.googleapis.com

REM Create Artifact Registry repository
echo Creating Artifact Registry repository...
call gcloud artifacts repositories describe !ARTIFACT_REGISTRY_REPO! ^
    --location=!ARTIFACT_REGISTRY_REGION! >nul 2>&1

if %errorlevel% equ 0 (
    echo Repository already exists
) else (
    call gcloud artifacts repositories create !ARTIFACT_REGISTRY_REPO! ^
        --repository-format=docker ^
        --location=!ARTIFACT_REGISTRY_REGION! ^
        --description="Todo App Docker Images"
    echo Repository created
)

REM Configure Docker authentication
echo Configuring Docker authentication...
call gcloud auth configure-docker !ARTIFACT_REGISTRY_REGION!-docker.pkg.dev

REM Create .env.gcp file with configuration
echo Creating .env.gcp configuration file...
(
    echo # GCP Configuration
    echo GCP_PROJECT_ID=!GCP_PROJECT_ID!
    echo GCP_REGION=!GCP_REGION!
    echo ARTIFACT_REGISTRY_REPO=!ARTIFACT_REGISTRY_REPO!
    echo ARTIFACT_REGISTRY_REGION=!ARTIFACT_REGISTRY_REGION!
    echo ARTIFACT_REGISTRY_URL=!ARTIFACT_REGISTRY_REGION!-docker.pkg.dev/!GCP_PROJECT_ID!/!ARTIFACT_REGISTRY_REPO!
    echo.
    echo # Service Names
    echo BACKEND_SERVICE_NAME=todo-backend
    echo FRONTEND_SERVICE_NAME=todo-frontend
    echo.
    echo # Resource Configuration
    echo BACKEND_MEMORY=512Mi
    echo BACKEND_CPU=1
    echo FRONTEND_MEMORY=512Mi
    echo FRONTEND_CPU=1
    echo MAX_INSTANCES=10
) > .env.gcp

echo Configuration saved to .env.gcp
echo.
echo === Setup Complete ===
echo.
echo Next steps:
echo 1. Update .env.gcp with your database credentials
echo 2. Run: deploy-all.bat
echo.
echo Or deploy manually:
echo deploy-backend.bat
echo deploy-frontend.bat
echo.
pause
