@echo off
REM Deploy Backend to Google Cloud Run (Windows)

setlocal enabledelayedexpansion

echo.
echo === Deploying Backend to Cloud Run ===
echo.

REM Load configuration
if not exist .env.gcp (
    echo Error: .env.gcp not found. Run setup-gcp.bat first
    exit /b 1
)

REM Read .env.gcp
for /f "tokens=1,2 delims==" %%a in (.env.gcp) do (
    if "%%a"=="GCP_PROJECT_ID" set GCP_PROJECT_ID=%%b
    if "%%a"=="GCP_REGION" set GCP_REGION=%%b
    if "%%a"=="ARTIFACT_REGISTRY_REPO" set ARTIFACT_REGISTRY_REPO=%%b
    if "%%a"=="ARTIFACT_REGISTRY_REGION" set ARTIFACT_REGISTRY_REGION=%%b
    if "%%a"=="ARTIFACT_REGISTRY_URL" set ARTIFACT_REGISTRY_URL=%%b
    if "%%a"=="BACKEND_SERVICE_NAME" set BACKEND_SERVICE_NAME=%%b
    if "%%a"=="BACKEND_MEMORY" set BACKEND_MEMORY=%%b
    if "%%a"=="BACKEND_CPU" set BACKEND_CPU=%%b
    if "%%a"=="MAX_INSTANCES" set MAX_INSTANCES=%%b
)

echo Project: !GCP_PROJECT_ID!
echo Region: !GCP_REGION!
echo Service: !BACKEND_SERVICE_NAME!
echo.

set IMAGE_NAME=!ARTIFACT_REGISTRY_URL!/backend:latest

echo Building Docker image...
docker build -f infra/docker/Dockerfile.backend ^
    -t !IMAGE_NAME! .

if %errorlevel% neq 0 (
    echo Docker build failed
    exit /b 1
)

echo Docker image built successfully
echo.

echo Pushing image to Artifact Registry...
docker push !IMAGE_NAME!

if %errorlevel% neq 0 (
    echo Docker push failed
    exit /b 1
)

echo Image pushed successfully
echo.

REM Get database credentials
if "!DATABASE_URL!"=="" (
    echo Reading DATABASE_URL from backend/.env...
    if exist backend\.env (
        for /f "tokens=1,2 delims==" %%a in (backend\.env) do (
            if "%%a"=="DATABASE_URL" set DATABASE_URL=%%b
            if "%%a"=="DATABASE_URL_UNPOOLED" set DATABASE_URL_UNPOOLED=%%b
        )
    ) else (
        echo Error: DATABASE_URL not set and backend/.env not found
        exit /b 1
    )
)

echo Deploying to Cloud Run...
call gcloud run deploy !BACKEND_SERVICE_NAME! ^
    --image !IMAGE_NAME! ^
    --platform managed ^
    --region !GCP_REGION! ^
    --memory !BACKEND_MEMORY! ^
    --cpu !BACKEND_CPU! ^
    --timeout 3600 ^
    --max-instances !MAX_INSTANCES! ^
    --allow-unauthenticated ^
    --set-env-vars DATABASE_URL="!DATABASE_URL!",DATABASE_URL_UNPOOLED="!DATABASE_URL_UNPOOLED!",PORT=8080 ^
    --quiet

if %errorlevel% neq 0 (
    echo Cloud Run deployment failed
    exit /b 1
)

echo Backend deployed successfully!
echo.

REM Get service URL
for /f %%i in ('gcloud run services describe !BACKEND_SERVICE_NAME! --region !GCP_REGION! --format "value(status.url)"') do set BACKEND_URL=%%i

echo Backend URL: !BACKEND_URL!
echo.
echo Next: Deploy frontend with:
echo set BACKEND_URL=!BACKEND_URL!
echo deploy-frontend.bat
echo.
pause
