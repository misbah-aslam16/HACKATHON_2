@echo off
REM Deploy Frontend to Google Cloud Run (Windows)

setlocal enabledelayedexpansion

echo.
echo === Deploying Frontend to Cloud Run ===
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
    if "%%a"=="FRONTEND_SERVICE_NAME" set FRONTEND_SERVICE_NAME=%%b
    if "%%a"=="FRONTEND_MEMORY" set FRONTEND_MEMORY=%%b
    if "%%a"=="FRONTEND_CPU" set FRONTEND_CPU=%%b
    if "%%a"=="MAX_INSTANCES" set MAX_INSTANCES=%%b
)

echo Project: !GCP_PROJECT_ID!
echo Region: !GCP_REGION!
echo Service: !FRONTEND_SERVICE_NAME!
echo.

REM Get backend URL
if "!BACKEND_URL!"=="" (
    echo Retrieving backend URL...
    for /f %%i in ('gcloud run services describe todo-backend --region !GCP_REGION! --format "value(status.url)" 2^>nul') do set BACKEND_URL=%%i
    
    if "!BACKEND_URL!"=="" (
        echo Error: Could not retrieve backend URL. Deploy backend first.
        exit /b 1
    )
)

echo Backend URL: !BACKEND_URL!
echo.

set IMAGE_NAME=!ARTIFACT_REGISTRY_URL!/frontend:latest

echo Building Docker image...
docker build -f infra/docker/Dockerfile.frontend ^
    --build-arg NEXT_PUBLIC_BACKEND_URL=!BACKEND_URL! ^
    --build-arg NEXT_PUBLIC_APP_URL=https://!FRONTEND_SERVICE_NAME!-xxxxx.run.app ^
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

REM Get database and auth credentials
if "!DATABASE_URL!"=="" (
    echo Reading credentials from todo-app-fullstack\.env...
    if exist todo-app-fullstack\.env (
        for /f "tokens=1,2 delims==" %%a in (todo-app-fullstack\.env) do (
            if "%%a"=="DATABASE_URL" set DATABASE_URL=%%b
            if "%%a"=="DATABASE_URL_UNPOOLED" set DATABASE_URL_UNPOOLED=%%b
            if "%%a"=="AUTH_SECRET" set AUTH_SECRET=%%b
            if "%%a"=="BETTER_AUTH_SECRET" set BETTER_AUTH_SECRET=%%b
        )
    ) else (
        echo Error: DATABASE_URL not set and todo-app-fullstack\.env not found
        exit /b 1
    )
)

echo Deploying to Cloud Run...
call gcloud run deploy !FRONTEND_SERVICE_NAME! ^
    --image !IMAGE_NAME! ^
    --platform managed ^
    --region !GCP_REGION! ^
    --memory !FRONTEND_MEMORY! ^
    --cpu !FRONTEND_CPU! ^
    --timeout 3600 ^
    --max-instances !MAX_INSTANCES! ^
    --allow-unauthenticated ^
    --set-env-vars NEXT_PUBLIC_BACKEND_URL="!BACKEND_URL!",DATABASE_URL="!DATABASE_URL!",DATABASE_URL_UNPOOLED="!DATABASE_URL_UNPOOLED!",AUTH_SECRET="!AUTH_SECRET!",BETTER_AUTH_SECRET="!BETTER_AUTH_SECRET!",PORT=3000 ^
    --quiet

if %errorlevel% neq 0 (
    echo Cloud Run deployment failed
    exit /b 1
)

echo Frontend deployed successfully!
echo.

REM Get service URL
for /f %%i in ('gcloud run services describe !FRONTEND_SERVICE_NAME! --region !GCP_REGION! --format "value(status.url)"') do set FRONTEND_URL=%%i

echo Frontend URL: !FRONTEND_URL!
echo.
echo === Deployment Complete ===
echo Backend: !BACKEND_URL!
echo Frontend: !FRONTEND_URL!
echo.
pause
