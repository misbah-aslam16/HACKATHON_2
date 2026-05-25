"""
JWT Authentication for FastAPI
Verifies tokens issued by Better Auth (frontend)
Shared secret: BETTER_AUTH_SECRET env var
"""

import os
import jwt
import uuid
from datetime import datetime, timedelta
from fastapi import HTTPException, Header, APIRouter, Depends
from sqlmodel import Session, select
from typing import Optional
from pydantic import BaseModel

from db import get_session
from models.models import User, Session as DBSession, Account

SECRET = os.getenv("BETTER_AUTH_SECRET", "fallback-secret-change-this")
router = APIRouter()


class AuthUser:
    def __init__(self, id: str, email: str = ""):
        self.id = id
        self.email = email


def get_current_user(
    authorization: Optional[str] = Header(default=None),
    x_user_id: Optional[str] = Header(default=None, alias="x-user-id"),
) -> AuthUser:
    """
    FastAPI dependency — extracts and verifies the authenticated user.

    Priority:
    1. JWT token from Authorization: Bearer <token> header
    2. x-user-id header (dev/testing fallback)
    3. Raises 401 if neither is present
    """
    # Try JWT first
    if authorization and authorization.startswith("Bearer "):
        token = authorization.split(" ", 1)[1]
        try:
            payload = jwt.decode(
                token,
                SECRET,
                algorithms=["HS256"],
                options={"verify_exp": True},
            )
            user_id = payload.get("sub") or payload.get("userId") or payload.get("id")
            email = payload.get("email", "")
            if user_id:
                return AuthUser(id=str(user_id), email=email)
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=401, detail="Token expired")
        except jwt.InvalidTokenError:
            raise HTTPException(status_code=401, detail="Invalid token")

    # Dev fallback: x-user-id header
    if x_user_id:
        return AuthUser(id=x_user_id)

    raise HTTPException(status_code=401, detail="Authentication required")


def verify_user_access(user_id_in_url: str, current_user: AuthUser):
    """Ensure the authenticated user matches the user_id in the URL."""
    if current_user.id != user_id_in_url:
        raise HTTPException(
            status_code=403,
            detail="Access denied: you can only access your own data"
        )


# ============================================
# REQUEST/RESPONSE SCHEMAS
# ============================================

class SignupRequest(BaseModel):
    email: str
    password: str
    name: Optional[str] = None


class SigninRequest(BaseModel):
    email: str
    password: str


class AuthResponse(BaseModel):
    id: str
    email: str
    name: Optional[str] = None
    avatar_url: Optional[str] = None
    token: str
    expires_at: datetime


class SessionResponse(BaseModel):
    id: str
    user_id: str
    token: str
    expires_at: datetime
    created_at: datetime


# ============================================
# AUTH ENDPOINTS
# ============================================

@router.post("/api/auth/signup", response_model=AuthResponse)
async def signup(
    body: SignupRequest,
    session: Session = Depends(get_session),
):
    """Create a new user account."""
    try:
        # Check if user already exists
        existing = session.exec(
            select(User).where(User.email == body.email)
        ).first()
        
        if existing:
            raise HTTPException(status_code=409, detail="Email already registered")
        
        # Create new user
        user_id = str(uuid.uuid4())
        user = User(
            id=user_id,
            email=body.email,
            name=body.name or body.email.split("@")[0],
            emailVerified=False,
        )
        session.add(user)
        session.flush()  # Flush to get the user in the session
        
        # Create account with password
        account = Account(
            id=str(uuid.uuid4()),
            user_id=user_id,
            account_id=body.email,
            provider_id="credentials",
            password=body.password,
        )
        session.add(account)
        session.commit()
        session.refresh(user)
        
        # Generate JWT token
        expires_at = datetime.utcnow() + timedelta(days=7)
        token = jwt.encode(
            {
                "sub": user_id,
                "email": user.email,
                "exp": expires_at,
            },
            SECRET,
            algorithm="HS256",
        )
        
        return AuthResponse(
            id=user.id,
            email=user.email,
            name=user.name,
            avatar_url=user.avatarUrl,
            token=token,
            expires_at=expires_at,
        )
    except HTTPException:
        raise
    except Exception as e:
        print(f"Signup error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Signup failed: {str(e)}")


# Better Auth compatible endpoints (what the frontend expects)
@router.post("/api/auth/sign-up/email", response_model=AuthResponse)
async def better_auth_signup(
    body: SignupRequest,
    session: Session = Depends(get_session),
):
    """Better Auth compatible signup endpoint."""
    return await signup(body, session)


@router.post("/api/auth/signin", response_model=AuthResponse)
async def signin(
    body: SigninRequest,
    session: Session = Depends(get_session),
):
    """Login user with email and password."""
    try:
        user = session.exec(
            select(User).where(User.email == body.email)
        ).first()
        
        if not user:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Check password (in production, use bcrypt or similar)
        account = session.exec(
            select(Account).where(
                Account.user_id == user.id,
                Account.provider_id == "credentials"
            )
        ).first()
        
        if not account or account.password != body.password:
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Generate JWT token
        expires_at = datetime.utcnow() + timedelta(days=7)
        token = jwt.encode(
            {
                "sub": user.id,
                "email": user.email,
                "exp": expires_at,
            },
            SECRET,
            algorithm="HS256",
        )
        
        # Create session record
        db_session = DBSession(
            id=str(uuid.uuid4()),
            user_id=user.id,
            token=token,
            expires_at=expires_at,
        )
        session.add(db_session)
        session.commit()
        
        return AuthResponse(
            id=user.id,
            email=user.email,
            name=user.name,
            avatar_url=user.avatarUrl,
            token=token,
            expires_at=expires_at,
        )
    except HTTPException:
        raise
    except Exception as e:
        print(f"Signin error: {str(e)}")
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=f"Signin failed: {str(e)}")


# Better Auth compatible endpoints
@router.post("/api/auth/sign-in/email", response_model=AuthResponse)
async def better_auth_signin(
    body: SigninRequest,
    session: Session = Depends(get_session),
):
    """Better Auth compatible signin endpoint."""
    return await signin(body, session)


@router.post("/api/auth/signout")
async def signout(
    current_user: AuthUser = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    """Logout user by invalidating session."""
    # In a real app, you'd invalidate the token here
    return {"message": "Signed out successfully"}


@router.get("/api/auth/session", response_model=SessionResponse)
async def get_session_info(
    current_user: AuthUser = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    """Get current session information."""
    db_session = session.exec(
        select(DBSession).where(DBSession.user_id == current_user.id)
    ).first()
    
    if not db_session:
        raise HTTPException(status_code=404, detail="Session not found")
    
    return SessionResponse(
        id=db_session.id,
        user_id=db_session.user_id,
        token=db_session.token,
        expires_at=db_session.expires_at,
        created_at=db_session.created_at,
    )


# Better Auth compatible endpoint
@router.get("/api/auth/get-session", response_model=SessionResponse)
async def better_auth_get_session(
    current_user: AuthUser = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    """Better Auth compatible get session endpoint."""
    return await get_session_info(current_user, session)


@router.post("/api/auth/refresh")
async def refresh_token(
    current_user: AuthUser = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    """Refresh JWT token."""
    user = session.exec(
        select(User).where(User.id == current_user.id)
    ).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Generate new token
    expires_at = datetime.utcnow() + timedelta(days=7)
    token = jwt.encode(
        {
            "sub": user.id,
            "email": user.email,
            "exp": expires_at,
        },
        SECRET,
        algorithm="HS256",
    )
    
    return AuthResponse(
        id=user.id,
        email=user.email,
        name=user.name,
        avatar_url=user.avatarUrl,
        token=token,
        expires_at=expires_at,
    )
