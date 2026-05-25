# ✅ Database Schema Fix - FINAL SOLUTION

## Problem
The backend was crashing with this error:
```
RuntimeError: Passing sa_column_kwargs is not supported when also passing a sa_column
```

And then after that was partially fixed:
```
column "user_id" of relation "account" does not exist
```

## Root Cause
The Python models were trying to use **camelCase** field names with `sa_column_kwargs` mappings, but the actual PostgreSQL database tables were created with **snake_case** column names.

When the code tried to insert data, it was using snake_case field names (like `user_id`) but the models were configured to map to camelCase columns (like `userId`), causing a mismatch.

## Solution
**Reverted all models to use snake_case** to match the actual database schema.

### Changes Made

#### 1. **User Model** (`backend/models/models.py`)
```python
# BEFORE (camelCase with mapping)
emailVerified: bool = Field(default=False, sa_column_kwargs={"name": "emailVerified"})
avatarUrl: Optional[str] = Field(default=None, sa_column_kwargs={"name": "avatarUrl"})
createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})

# AFTER (snake_case - matches DB)
email_verified: bool = Field(default=False)
avatar_url: Optional[str] = Field(default=None)
created_at: datetime = Field(default_factory=datetime.utcnow)
```

#### 2. **Session Model** (`backend/models/models.py`)
```python
# BEFORE
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
expiresAt: datetime = Field(sa_column_kwargs={"name": "expiresAt"})

# AFTER
user_id: str = Field(foreign_key="users.id", index=True)
expires_at: datetime = Field()
```

#### 3. **Account Model** (`backend/models/models.py`)
```python
# BEFORE
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
accountId: str = Field(sa_column_kwargs={"name": "accountId"})
providerId: str = Field(sa_column_kwargs={"name": "providerId"})

# AFTER
user_id: str = Field(foreign_key="users.id", index=True)
account_id: str = Field()
provider_id: str = Field()
```

#### 4. **Todo Model** (`backend/models/models.py`)
```python
# BEFORE
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
dueDate: Optional[datetime] = Field(default=None, sa_column_kwargs={"name": "dueDate"})
assignedTo: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="assignedTo"))

# AFTER
user_id: str = Field(foreign_key="users.id", index=True)
due_date: Optional[datetime] = Field(default=None)
assigned_to: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="assigned_to"))
```

#### 5. **Comment Model** (`backend/models/models.py`)
```python
# BEFORE
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
todoId: str = Field(foreign_key="todos.id", index=True, sa_column_kwargs={"name": "todoId"})

# AFTER
user_id: str = Field(foreign_key="users.id", index=True)
todo_id: str = Field(foreign_key="todos.id", index=True)
```

#### 6. **Auth Routes** (`backend/routes/auth.py`)
Updated all field references to use snake_case:
```python
# BEFORE
user = User(
    id=user_id,
    email=body.email,
    name=body.name or body.email.split("@")[0],
    emailVerified=False,  # ❌ Wrong
)

# AFTER
user = User(
    id=user_id,
    email=body.email,
    name=body.name or body.email.split("@")[0],
    email_verified=False,  # ✅ Correct
)
```

## Database Schema (Actual)
The actual PostgreSQL database has these column names:

### users table
- `id` (UUID)
- `email` (VARCHAR)
- `name` (VARCHAR)
- `email_verified` (BOOLEAN)
- `image` (VARCHAR)
- `avatar_url` (VARCHAR)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### account table
- `id` (UUID)
- `user_id` (UUID, FK)
- `account_id` (VARCHAR)
- `provider_id` (VARCHAR)
- `access_token` (VARCHAR)
- `refresh_token` (VARCHAR)
- `id_token` (VARCHAR)
- `access_token_expires_at` (TIMESTAMP)
- `refresh_token_expires_at` (TIMESTAMP)
- `scope` (VARCHAR)
- `password` (VARCHAR)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)

### session table
- `id` (UUID)
- `user_id` (UUID, FK)
- `expires_at` (TIMESTAMP)
- `token` (VARCHAR)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)
- `ip_address` (VARCHAR)
- `user_agent` (VARCHAR)

### todos table
- `id` (UUID)
- `title` (VARCHAR)
- `description` (TEXT)
- `completed` (BOOLEAN)
- `priority` (VARCHAR)
- `due_date` (TIMESTAMP)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)
- `user_id` (UUID, FK)
- `tags` (JSON)
- `assigned_to` (JSON)
- `version` (INTEGER)
- `last_modified_by` (VARCHAR)
- `recurrence_pattern` (VARCHAR)
- `reminder_offset` (INTEGER)
- `reminder_enabled` (BOOLEAN)
- `suggestion_dismissed` (BOOLEAN)

### comments table
- `id` (UUID)
- `content` (TEXT)
- `created_at` (TIMESTAMP)
- `updated_at` (TIMESTAMP)
- `user_id` (UUID, FK)
- `todo_id` (UUID, FK)
- `mentions` (JSON)
- `resolved` (BOOLEAN)

## What to Do Now

### 1. **Redeploy Backend on Railway**
1. Go to: https://railway.app/dashboard
2. Click on your backend service
3. Click "Deployments" tab
4. Click "Deploy" button
5. Wait 5-10 minutes for deployment

### 2. **Test Signup**
```bash
curl -X POST http://localhost:8000/api/auth/sign-up/email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

Expected response (200 OK):
```json
{
  "id": "uuid-here",
  "email": "test@example.com",
  "name": "Test User",
  "avatar_url": null,
  "token": "jwt-token-here",
  "expires_at": "2026-06-01T12:00:00"
}
```

### 3. **Test Signin**
```bash
curl -X POST http://localhost:8000/api/auth/sign-in/email \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123"
  }'
```

### 4. **Test Get Session**
```bash
curl -X GET http://localhost:8000/api/auth/get-session \
  -H "Authorization: Bearer <token-from-signup>"
```

## Commits
- **1393250**: "fix: revert to snake_case field names to match actual database schema"

## Status
✅ **READY TO DEPLOY**

All models now use snake_case which matches the actual PostgreSQL database schema. The backend should start without errors and signup/signin should work correctly.
