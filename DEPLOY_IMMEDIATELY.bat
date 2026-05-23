@echo off
REM ⚡ IMMEDIATE DEPLOYMENT SCRIPT
REM Run this to deploy your application to Cloud Run NOW

setlocal enabledelayedexpansion

REM Configuration
set GCP_PROJECT_ID=todo-497210
set GCP_REGION=us-central1
set ARTIFACT_REGISTRY_REPO=todo-app
set ARTIFACT_REGISTRY_REGION=us-central1
set BACKEND_SERVICE_NAME=todo-backend
set FRONTEND_SERVICE_NAME=todo-frontend

echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║         🚀 DEPLOYING TODO APP TO CLOUD RUN                    ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.

REM Step 1: Authenticate
echo Step 1: Authenticating with Google Cloud...
call gcloud auth login
call gcloud config set project !GCP_PROJECT_ID!
echo ✅ Authenticated
echo.

REM Step 2: Enable APIs
echo Step 2: Enabling required APIs...
call gcloud services enable run.googleapis.com artifactregistry.googleapis.com cloudbuild.googleapis.com
echo ✅ APIs enabled
echo.

REM Step 3: Create Artifact Registry
echo Step 3: Creating Artifact Registry repository...
call gcloud artifacts repositories create !ARTIFACT_REGISTRY_REPO! ^
  --repository-format=docker ^
  --location=!ARTIFACT_REGISTRY_REGION! ^
  --description="Todo App Docker Images" 2>nul || echo Repository already exists
echo ✅ Artifact Registry ready
echo.

REM Step 4: Configure Docker
echo Step 4: Configuring Docker authentication...
call gcloud auth configure-docker !ARTIFACT_REGISTRY_REGION!-docker.pkg.dev
echo ✅ Docker configured
echo.

REM Step 5: Build and push backend
echo Step 5: Building and pushing backend image...
set BACKEND_IMAGE=!ARTIFACT_REGISTRY_REGION!-docker.pkg.dev/!GCP_PROJECT_ID!/!ARTIFACT_REGISTRY_REPO!/backend:latest
docker build -f infra/docker/Dockerfile.backend ^
  -t !BACKEND_IMAGE! .
docker push !BACKEND_IMAGE!
echo ✅ Backend image pushed
echo.

REM Step 6: Build and push frontend
echo Step 6: Building and pushing frontend image...
set FRONTEND_IMAGE=!ARTIFACT_REGISTRY_REGION!-docker.pkg.dev/!GCP_PROJECT_ID!/!ARTIFACT_REGISTRY_REPO!/frontend:latest
docker build -f infra/docker/Dockerfile.frontend ^
  -t !FRONTEND_IMAGE! .
docker push !FRONTEND_IMAGE!
echo ✅ Frontend image pushed
echo.

REM Step 7: Deploy backend
echo Step 7: Deploying backend to Cloud Run...
call gcloud run deploy !BACKEND_SERVICE_NAME! ^
  --image !BACKEND_IMAGE! ^
  --platform managed ^
  --region !GCP_REGION! ^
  --memory 512Mi ^
  --cpu 1 ^
  --timeout 3600 ^
  --max-instances 10 ^
  --allow-unauthenticated ^
  --set-env-vars DATABASE_URL="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require",DATABASE_URL_UNPOOLED="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require",PORT=8080 ^
  --quiet
echo ✅ Backend deployed
echo.

REM Step 8: Get backend URL
echo Step 8: Getting backend URL...
for /f %%i in ('gcloud run services describe !BACKEND_SERVICE_NAME! --region !GCP_REGION! --format "value(status.url)"') do set BACKEND_URL=%%i
echo ✅ Backend URL: !BACKEND_URL!
echo.

REM Step 9: Deploy frontend
echo Step 9: Deploying frontend to Cloud Run...
call gcloud run deploy !FRONTEND_SERVICE_NAME! ^
  --image !FRONTEND_IMAGE! ^
  --platform managed ^
  --region !GCP_REGION! ^
  --memory 512Mi ^
  --cpu 1 ^
  --timeout 3600 ^
  --max-instances 10 ^
  --allow-unauthenticated ^
  --set-env-vars NEXT_PUBLIC_BACKEND_URL="!BACKEND_URL!",DATABASE_URL="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require",DATABASE_URL_UNPOOLED="postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require",AUTH_SECRET="dev-better-auth-secret-change-in-production",BETTER_AUTH_SECRET="wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=",PORT=3000 ^
  --quiet
echo ✅ Frontend deployed
echo.

REM Step 10: Get frontend URL
echo Step 10: Getting frontend URL...
for /f %%i in ('gcloud run services describe !FRONTEND_SERVICE_NAME! --region !GCP_REGION! --format "value(status.url)"') do set FRONTEND_URL=%%i
echo ✅ Frontend URL: !FRONTEND_URL!
echo.

REM Summary
echo.
echo ╔════════════════════════════════════════════════════════════════╗
echo ║                                                                ║
echo ║         ✅ DEPLOYMENT COMPLETE!                               ║
echo ║                                                                ║
echo ╚════════════════════════════════════════════════════════════════╝
echo.
echo 🎉 Your application is now live!
echo.
echo 📱 Frontend (Next.js):
echo    !FRONTEND_URL!
echo.
echo 🔧 Backend (FastAPI):
echo    !BACKEND_URL!
echo.
echo 📊 Cloud Run Console:
echo    https://console.cloud.google.com/run?project=!GCP_PROJECT_ID!
echo.
echo 📝 View Logs:
echo    gcloud run logs read !BACKEND_SERVICE_NAME! --region !GCP_REGION! --follow
echo    gcloud run logs read !FRONTEND_SERVICE_NAME! --region !GCP_REGION! --follow
echo.
pause
