# 📋 What Was Changed - Complete List

## Problem
Backend was crashing with:
```
RuntimeError: Passing sa_column_kwargs is not supported when also passing a sa_column
column "user_id" of relation "account" does not exist
```

## Root Cause
Python models were using **camelCase** with `sa_column_kwargs` mappings, but the actual PostgreSQL database had **snake_case** columns.

## Solution
Reverted all models to use **snake_case** to match the actual database.

---

## File 1: `backend/models/models.py`

### User Model
```python
# BEFORE
emailVerified: bool = Field(default=False, sa_column_kwargs={"name": "emailVerified"})
image: Optional[str] = None
avatarUrl: Optional[str] = Field(default=None, sa_column_kwargs={"name": "avatarUrl"})
createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})

# AFTER
email_verified: bool = Field(default=False)
image: Optional[str] = None
avatar_url: Optional[str] = Field(default=None)
created_at: datetime = Field(default_factory=datetime.utcnow)
updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Session Model
```python
# BEFORE
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
expiresAt: datetime = Field(sa_column_kwargs={"name": "expiresAt"})
token: str = Field(unique=True, index=True)
createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
ipAddress: Optional[str] = Field(default=None, sa_column_kwargs={"name": "ipAddress"})
userAgent: Optional[str] = Field(default=None, sa_column_kwargs={"name": "userAgent"})

# AFTER
user_id: str = Field(foreign_key="users.id", index=True)
expires_at: datetime = Field()
token: str = Field(unique=True, index=True)
created_at: datetime = Field(default_factory=datetime.utcnow)
updated_at: datetime = Field(default_factory=datetime.utcnow)
ip_address: Optional[str] = Field(default=None)
user_agent: Optional[str] = Field(default=None)
```

### Account Model
```python
# BEFORE
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
accountId: str = Field(sa_column_kwargs={"name": "accountId"})
providerId: str = Field(sa_column_kwargs={"name": "providerId"})
accessToken: Optional[str] = Field(default=None, sa_column_kwargs={"name": "accessToken"})
refreshToken: Optional[str] = Field(default=None, sa_column_kwargs={"name": "refreshToken"})
idToken: Optional[str] = Field(default=None, sa_column_kwargs={"name": "idToken"})
accessTokenExpiresAt: Optional[datetime] = Field(default=None, sa_column_kwargs={"name": "accessTokenExpiresAt"})
refreshTokenExpiresAt: Optional[datetime] = Field(default=None, sa_column_kwargs={"name": "refreshTokenExpiresAt"})
scope: Optional[str] = None
password: Optional[str] = None
createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})

# AFTER
user_id: str = Field(foreign_key="users.id", index=True)
account_id: str = Field()
provider_id: str = Field()
access_token: Optional[str] = Field(default=None)
refresh_token: Optional[str] = Field(default=None)
id_token: Optional[str] = Field(default=None)
access_token_expires_at: Optional[datetime] = Field(default=None)
refresh_token_expires_at: Optional[datetime] = Field(default=None)
scope: Optional[str] = None
password: Optional[str] = None
created_at: datetime = Field(default_factory=datetime.utcnow)
updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Todo Model
```python
# BEFORE
dueDate: Optional[datetime] = Field(default=None, sa_column_kwargs={"name": "dueDate"})
createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
tags: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="tags"))
assignedTo: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="assignedTo"))
version: int = Field(default=1)
lastModifiedBy: Optional[str] = Field(default=None, sa_column_kwargs={"name": "lastModifiedBy"})
recurrencePattern: Optional[str] = Field(default=None, sa_column_kwargs={"name": "recurrencePattern"})
reminderOffset: Optional[int] = Field(default=None, sa_column_kwargs={"name": "reminderOffset"})
reminderEnabled: bool = Field(default=False, sa_column_kwargs={"name": "reminderEnabled"})
suggestionDismissed: bool = Field(default=False, sa_column_kwargs={"name": "suggestionDismissed"})

# AFTER
due_date: Optional[datetime] = Field(default=None)
created_at: datetime = Field(default_factory=datetime.utcnow)
updated_at: datetime = Field(default_factory=datetime.utcnow)
user_id: str = Field(foreign_key="users.id", index=True)
tags: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="tags"))
assigned_to: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="assigned_to"))
version: int = Field(default=1)
last_modified_by: Optional[str] = Field(default=None)
recurrence_pattern: Optional[str] = Field(default=None)
reminder_offset: Optional[int] = Field(default=None)
reminder_enabled: bool = Field(default=False)
suggestion_dismissed: bool = Field(default=False)
```

### Comment Model
```python
# BEFORE
createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
todoId: str = Field(foreign_key="todos.id", index=True, sa_column_kwargs={"name": "todoId"})
mentions: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="mentions"))

# AFTER
created_at: datetime = Field(default_factory=datetime.utcnow)
updated_at: datetime = Field(default_factory=datetime.utcnow)
user_id: str = Field(foreign_key="users.id", index=True)
todo_id: str = Field(foreign_key="todos.id", index=True)
mentions: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="mentions"))
```

---

## File 2: `backend/routes/auth.py`

### Signup Endpoint
```python
# BEFORE
user = User(
    id=user_id,
    email=body.email,
    name=body.name or body.email.split("@")[0],
    emailVerified=False,  # ❌ Wrong
)
# ...
account = Account(
    id=str(uuid.uuid4()),
    userId=user_id,  # ❌ Wrong
    accountId=body.email,  # ❌ Wrong
    providerId="credentials",  # ❌ Wrong
    password=body.password,
)
# ...
return AuthResponse(
    id=user.id,
    email=user.email,
    name=user.name,
    avatar_url=user.avatarUrl,  # ❌ Wrong
    token=token,
    expires_at=expires_at,
)

# AFTER
user = User(
    id=user_id,
    email=body.email,
    name=body.name or body.email.split("@")[0],
    email_verified=False,  # ✅ Correct
)
# ...
account = Account(
    id=str(uuid.uuid4()),
    user_id=user_id,  # ✅ Correct
    account_id=body.email,  # ✅ Correct
    provider_id="credentials",  # ✅ Correct
    password=body.password,
)
# ...
return AuthResponse(
    id=user.id,
    email=user.email,
    name=user.name,
    avatar_url=user.avatar_url,  # ✅ Correct
    token=token,
    expires_at=expires_at,
)
```

### Signin Endpoint
```python
# BEFORE
account = session.exec(
    select(Account).where(
        Account.userId == user.id,  # ❌ Wrong
        Account.providerId == "credentials"  # ❌ Wrong
    )
).first()
# ...
db_session = DBSession(
    id=str(uuid.uuid4()),
    userId=user.id,  # ❌ Wrong
    token=token,
    expiresAt=expires_at,  # ❌ Wrong
)
# ...
return AuthResponse(
    id=user.id,
    email=user.email,
    name=user.name,
    avatar_url=user.avatarUrl,  # ❌ Wrong
    token=token,
    expires_at=expires_at,
)

# AFTER
account = session.exec(
    select(Account).where(
        Account.user_id == user.id,  # ✅ Correct
        Account.provider_id == "credentials"  # ✅ Correct
    )
).first()
# ...
db_session = DBSession(
    id=str(uuid.uuid4()),
    user_id=user.id,  # ✅ Correct
    token=token,
    expires_at=expires_at,  # ✅ Correct
)
# ...
return AuthResponse(
    id=user.id,
    email=user.email,
    name=user.name,
    avatar_url=user.avatar_url,  # ✅ Correct
    token=token,
    expires_at=expires_at,
)
```

### Get Session Endpoint
```python
# BEFORE
db_session = session.exec(
    select(DBSession).where(DBSession.userId == current_user.id)  # ❌ Wrong
).first()

return SessionResponse(
    id=db_session.id,
    user_id=db_session.userId,  # ❌ Wrong
    token=db_session.token,
    expires_at=db_session.expiresAt,  # ❌ Wrong
    created_at=db_session.createdAt,  # ❌ Wrong
)

# AFTER
db_session = session.exec(
    select(DBSession).where(DBSession.user_id == current_user.id)  # ✅ Correct
).first()

return SessionResponse(
    id=db_session.id,
    user_id=db_session.user_id,  # ✅ Correct
    token=db_session.token,
    expires_at=db_session.expires_at,  # ✅ Correct
    created_at=db_session.created_at,  # ✅ Correct
)
```

---

## Summary of Changes

### Total Changes
- **2 files modified**
- **~50+ field references updated**
- **All camelCase → snake_case**
- **All sa_column_kwargs removed**

### Pattern
```
emailVerified → email_verified
avatarUrl → avatar_url
createdAt → created_at
updatedAt → updated_at
userId → user_id
expiresAt → expires_at
ipAddress → ip_address
userAgent → user_agent
accountId → account_id
providerId → provider_id
accessToken → access_token
refreshToken → refresh_token
idToken → id_token
accessTokenExpiresAt → access_token_expires_at
refreshTokenExpiresAt → refresh_token_expires_at
dueDate → due_date
assignedTo → assigned_to
lastModifiedBy → last_modified_by
recurrencePattern → recurrence_pattern
reminderOffset → reminder_offset
reminderEnabled → reminder_enabled
suggestionDismissed → suggestion_dismissed
todoId → todo_id
```

---

## Commits
```
1393250 - fix: revert to snake_case field names to match actual database schema
9f76af9 - docs: add schema fix and deployment guide
9d8ce84 - docs: add final status summary
8b81034 - docs: add deployment quick start guide
```

## Result
✅ All models now match the actual PostgreSQL database schema
✅ No more `RuntimeError` or column mismatch errors
✅ Backend should start without errors
✅ Signup/Signin should work correctly
