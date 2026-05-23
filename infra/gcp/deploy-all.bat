@echo off
REM Deploy Both Backend and Frontend to Google Cloud Run (Windows)

setlocal enabledelayedexpansion

echo.
echo === Todo App - Complete Cloud Run Deployment ===
echo.

REM Check if .env.gcp exists
if not exist .env.gcp (
    echo Error: .env.gcp not found
    echo Run setup-gcp.bat first to initialize GCP resources
    exit /b 1
)

REM Read .env.gcp
for /f "tokens=1,2 delims==" %%a in (.env.gcp) do (
    if "%%a"=="GCP_PROJECT_ID" set GCP_PROJECT_ID=%%b
    if "%%a"=="GCP_REGION" set GCP_REGION=%%b
    if "%%a"=="BACKEND_SERVICE_NAME" set BACKEND_SERVICE_NAME=%%b
    if "%%a"=="FRONTEND_SERVICE_NAME" set FRONTEND_SERVICE_NAME=%%b
)

REM Deploy backend
echo Step 1: Deploying Backend...
call deploy-backend.bat

if %errorlevel% neq 0 (
    echo Backend deployment failed
    exit /b 1
)

REM Get backend URL for frontend deployment
for /f %%i in ('gcloud run services describe !BACKEND_SERVICE_NAME! --region !GCP_REGION! --format "value(status.url)"') do set BACKEND_URL=%%i

REM Deploy frontend
echo Step 2: Deploying Frontend...
set BACKEND_URL=!BACKEND_URL!
call deploy-frontend.bat

if %errorlevel% neq 0 (
    echo Frontend deployment failed
    exit /b 1
)

REM Get URLs
for /f %%i in ('gcloud run services describe !FRONTEND_SERVICE_NAME! --region !GCP_REGION! --format "value(status.url)"') do set FRONTEND_URL=%%i

echo.
echo === Deployment Complete ===
echo.
echo Services deployed successfully!
echo.
echo Backend Service:
echo   Name: !BACKEND_SERVICE_NAME!
echo   URL: !BACKEND_URL!
echo   Region: !GCP_REGION!
echo.
echo Frontend Service:
echo   Name: !FRONTEND_SERVICE_NAME!
echo   URL: !FRONTEND_URL!
echo   Region: !GCP_REGION!
echo.
echo Useful Commands:
echo.
echo View logs:
echo   gcloud run logs read !BACKEND_SERVICE_NAME! --region !GCP_REGION! --limit 50
echo   gcloud run logs read !FRONTEND_SERVICE_NAME! --region !GCP_REGION! --limit 50
echo.
echo View service details:
echo   gcloud run services describe !BACKEND_SERVICE_NAME! --region !GCP_REGION!
echo   gcloud run services describe !FRONTEND_SERVICE_NAME! --region !GCP_REGION!
echo.
echo Update environment variables:
echo   gcloud run services update !BACKEND_SERVICE_NAME! --region !GCP_REGION! --update-env-vars KEY=VALUE
echo   gcloud run services update !FRONTEND_SERVICE_NAME! --region !GCP_REGION! --update-env-vars KEY=VALUE
echo.
echo Delete services:
echo   gcloud run services delete !BACKEND_SERVICE_NAME! --region !GCP_REGION!
echo   gcloud run services delete !FRONTEND_SERVICE_NAME! --region !GCP_REGION!
echo.
pause
