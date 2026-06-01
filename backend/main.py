"""
Phase III — AI-Powered Todo Chatbot
FastAPI + Gemini 2.5 Flash + MCP Tools + Neon PostgreSQL
"""

import os
from contextlib import asynccontextmanager

from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

# Local imports after load_dotenv so env vars are available  # noqa: E402
from db import create_db_and_tables  # noqa: E402
from routes.chat import router as chat_router  # noqa: E402
from routes.tasks import router as tasks_router  # noqa: E402
from routes.auth import router as auth_router  # noqa: E402
from routes.todos import router as todos_router  # noqa: E402


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Create DB tables on startup."""
    create_db_and_tables()
    yield


app = FastAPI(
    title="Todo AI Chatbot — Phase III",
    description="AI-powered todo management via Gemini 2.5 Flash + MCP tools",
    version="1.0.0",
    lifespan=lifespan,
)

# ============================================
# CORS CONFIGURATION
# ============================================
allowed_origins = [
    os.getenv("FRONTEND_URL", "http://localhost:3000"),
    "http://localhost:3000",
    "http://localhost:3001",
    "http://localhost:8000",
    "http://localhost:8080",
    "https://hackathon-2-tiqg.vercel.app",
    "https://todo-app-frontend.vercel.app",
]

# Add CORS middleware with proper credential support
app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"],
    allow_headers=["*"],
    expose_headers=["Set-Cookie"],
    max_age=600,
)

# ============================================
# ROUTE REGISTRATION
# ============================================
app.include_router(auth_router)
app.include_router(todos_router)
app.include_router(chat_router)
app.include_router(tasks_router)


@app.get("/")
def root():
    return {
        "name": "Todo AI Chatbot API",
        "phase": "III",
        "model": os.getenv("GEMINI_MODEL", "gemini-2.5-flash"),
        "status": "running",
        "docs": "/docs",
    }


@app.get("/health")
def health():
    return {"status": "ok"}
