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
    email_verified: bool = Field(default=False)
    image: Optional[str] = None
    avatar_url: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Relationships
    todos: list["Todo"] = Relationship(back_populates="user")
    comments: list["Comment"] = Relationship(back_populates="user")
    sessions: list["Session"] = Relationship(back_populates="user")
    accounts: list["Account"] = Relationship(back_populates="user")


class Session(SQLModel, table=True):
    __tablename__ = "session"
    
    id: str = Field(primary_key=True)
    user_id: str = Field(foreign_key="users.id", index=True)
    expires_at: datetime
    token: str = Field(unique=True, index=True)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    ip_address: Optional[str] = None
    user_agent: Optional[str] = None
    
    user: User = Relationship(back_populates="sessions")


class Account(SQLModel, table=True):
    __tablename__ = "account"
    
    id: str = Field(primary_key=True)
    user_id: str = Field(foreign_key="users.id", index=True)
    account_id: str
    provider_id: str
    access_token: Optional[str] = None
    refresh_token: Optional[str] = None
    id_token: Optional[str] = None
    access_token_expires_at: Optional[datetime] = None
    refresh_token_expires_at: Optional[datetime] = None
    scope: Optional[str] = None
    password: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    
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
    due_date: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    user_id: str = Field(foreign_key="users.id", index=True)
    tags: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON))  # JSON array
    assigned_to: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON))  # JSON array
    version: int = Field(default=1)
    last_modified_by: Optional[str] = None
    
    # Relationships
    user: User = Relationship(back_populates="todos")
    comments: list["Comment"] = Relationship(back_populates="todo")
    
    # Recurrence & reminders
    recurrence_pattern: Optional[str] = None  # none | daily | weekly | monthly
    reminder_offset: Optional[int] = None  # minutes before due date
    reminder_enabled: bool = Field(default=False)
    suggestion_dismissed: bool = Field(default=False)


class Comment(SQLModel, table=True):
    __tablename__ = "comments"
    
    id: str = Field(primary_key=True)
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
    user_id: str = Field(foreign_key="users.id", index=True)
    todo_id: str = Field(foreign_key="todos.id", index=True)
    mentions: str = Field(default="[]", sa_column=Column(SQLAlchemyJSON))  # JSON array
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
