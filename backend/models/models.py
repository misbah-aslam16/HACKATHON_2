from datetime import datetime
from typing import Optional
from sqlmodel import Field, SQLModel, Relationship, JSON, Column
from sqlalchemy import JSON as SQLAlchemyJSON
import json


# ============================================
# USER & AUTH MODELS
# ============================================

class User(SQLModel, table=True):
    __tablename__ = "users"
    
    id: str = Field(primary_key=True)
    email: str = Field(unique=True, index=True)
    name: Optional[str] = None
    emailVerified: bool = Field(default=False, sa_column_kwargs={"name": "emailVerified"})
    image: Optional[str] = None
    avatarUrl: Optional[str] = Field(default=None, sa_column_kwargs={"name": "avatarUrl"})
    createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
    updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
    
    # Relationships
    todos: list["Todo"] = Relationship(back_populates="user")
    comments: list["Comment"] = Relationship(back_populates="user")
    sessions: list["Session"] = Relationship(back_populates="user")
    accounts: list["Account"] = Relationship(back_populates="user")


class Session(SQLModel, table=True):
    __tablename__ = "session"
    
    id: str = Field(primary_key=True)
    userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
    expiresAt: datetime = Field(sa_column_kwargs={"name": "expiresAt"})
    token: str = Field(unique=True, index=True)
    createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
    updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
    ipAddress: Optional[str] = Field(default=None, sa_column_kwargs={"name": "ipAddress"})
    userAgent: Optional[str] = Field(default=None, sa_column_kwargs={"name": "userAgent"})
    
    user: User = Relationship(back_populates="sessions")


class Account(SQLModel, table=True):
    __tablename__ = "account"
    
    id: str = Field(primary_key=True)
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
    
    user: User = Relationship(back_populates="accounts")


# ============================================
# TODO & COMMENT MODELS
# ============================================

class Todo(SQLModel, table=True):
    __tablename__ = "todos"
    
    id: str = Field(primary_key=True)
    title: str
    description: Optional[str] = None
    completed: bool = Field(default=False)
    priority: str = Field(default="medium")  # low | medium | high
    dueDate: Optional[datetime] = Field(default=None, sa_column_kwargs={"name": "dueDate"})
    createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
    updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
    userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
    tags: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="tags"))  # JSON array
    assignedTo: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="assignedTo"))  # JSON array
    version: int = Field(default=1)
    lastModifiedBy: Optional[str] = Field(default=None, sa_column_kwargs={"name": "lastModifiedBy"})
    
    # Relationships
    user: User = Relationship(back_populates="todos")
    comments: list["Comment"] = Relationship(back_populates="todo")
    
    # Recurrence & reminders
    recurrencePattern: Optional[str] = Field(default=None, sa_column_kwargs={"name": "recurrencePattern"})  # none | daily | weekly | monthly
    reminderOffset: Optional[int] = Field(default=None, sa_column_kwargs={"name": "reminderOffset"})  # minutes before due date
    reminderEnabled: bool = Field(default=False, sa_column_kwargs={"name": "reminderEnabled"})
    suggestionDismissed: bool = Field(default=False, sa_column_kwargs={"name": "suggestionDismissed"})


class Comment(SQLModel, table=True):
    __tablename__ = "comments"
    
    id: str = Field(primary_key=True)
    content: str
    createdAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "createdAt"})
    updatedAt: datetime = Field(default_factory=datetime.utcnow, sa_column_kwargs={"name": "updatedAt"})
    userId: str = Field(foreign_key="users.id", index=True, sa_column_kwargs={"name": "userId"})
    todoId: str = Field(foreign_key="todos.id", index=True, sa_column_kwargs={"name": "todoId"})
    mentions: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON, name="mentions"))  # JSON array
    resolved: bool = Field(default=False)
    
    user: User = Relationship(back_populates="comments")
    todo: Todo = Relationship(back_populates="comments")


# ============================================
# LEGACY MODELS (for backward compatibility)
# ============================================

class TaskBase(SQLModel):
    title: str = Field(max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)
    completed: bool = Field(default=False)
    priority: str = Field(default="medium")
    due_date: Optional[datetime] = Field(default=None)
    recurrence_pattern: Optional[str] = Field(default=None)


class Task(TaskBase, table=True):
    __tablename__ = "chatbot_tasks"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class TaskCreate(TaskBase):
    pass


class TaskUpdate(SQLModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None
    priority: Optional[str] = None
    due_date: Optional[datetime] = None


class TaskRead(TaskBase):
    id: int
    user_id: str
    created_at: datetime
    updated_at: datetime


class Conversation(SQLModel, table=True):
    __tablename__ = "chatbot_conversations"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(index=True)
    title: Optional[str] = Field(default="New Chat")
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)

    messages: list["Message"] = Relationship(back_populates="conversation")


class Message(SQLModel, table=True):
    __tablename__ = "chatbot_messages"

    id: Optional[int] = Field(default=None, primary_key=True)
    conversation_id: int = Field(foreign_key="chatbot_conversations.id", index=True)
    user_id: str = Field(index=True)
    role: str
    content: str
    tool_calls: Optional[str] = Field(default=None)
    created_at: datetime = Field(default_factory=datetime.utcnow)

    conversation: Optional[Conversation] = Relationship(back_populates="messages")


# ============================================
# REQUEST / RESPONSE SCHEMAS
# ============================================

class ChatRequest(SQLModel):
    message: str
    conversation_id: Optional[int] = None


class ChatResponse(SQLModel):
    conversation_id: int
    response: str
    tool_calls: list[str] = []


# ============================================
# TODO API SCHEMAS
# ============================================

class TodoCreate(SQLModel):
    title: str
    description: Optional[str] = None
    priority: str = "medium"
    due_date: Optional[datetime] = None
    tags: list[str] = []
    recurrence_pattern: Optional[str] = None
    reminder_enabled: bool = False
    reminder_offset: Optional[int] = None


class TodoUpdate(SQLModel):
    title: Optional[str] = None
    description: Optional[str] = None
    completed: Optional[bool] = None
    priority: Optional[str] = None
    due_date: Optional[datetime] = None
    tags: Optional[list[str]] = None
    assigned_to: Optional[list[str]] = None
    recurrence_pattern: Optional[str] = None
    reminder_enabled: Optional[bool] = None
    reminder_offset: Optional[int] = None


class TodoRead(SQLModel):
    id: str
    title: str
    description: Optional[str] = None
    completed: bool
    priority: str
    due_date: Optional[datetime] = None
    created_at: datetime
    updated_at: datetime
    user_id: str
    tags: list[str] = []
    assigned_to: list[str] = []
    version: int
    last_modified_by: Optional[str] = None
    recurrence_pattern: Optional[str] = None
    reminder_enabled: bool = False
    reminder_offset: Optional[int] = None


class CommentCreate(SQLModel):
    content: str
    mentions: list[str] = []


class CommentRead(SQLModel):
    id: str
    content: str
    created_at: datetime
    updated_at: datetime
    user_id: str
    todo_id: str
    mentions: list[str] = []
    resolved: bool = False


class UserRead(SQLModel):
    id: str
    email: str
    name: Optional[str] = None
    avatar_url: Optional[str] = None
    created_at: datetime
    updated_at: datetime
