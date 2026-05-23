"""
REST Todos API — /api/todos
Spec-compliant endpoints for Todo CRUD operations.
"""

import uuid
import json
from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, Query
from sqlmodel import Session, select

from db import get_session
from models.models import (
    Todo, TodoCreate, TodoUpdate, TodoRead,
    Comment, CommentCreate, CommentRead,
    User, UserRead
)
from routes.auth import get_current_user, AuthUser

router = APIRouter()


def get_todo_or_404(todo_id: str, session: Session) -> Todo:
    """Get a todo by ID or raise 404."""
    todo = session.exec(
        select(Todo).where(Todo.id == todo_id)
    ).first()
    if not todo:
        raise HTTPException(status_code=404, detail=f"Todo {todo_id} not found")
    return todo


def verify_todo_ownership(todo: Todo, current_user: AuthUser):
    """Ensure the current user owns the todo."""
    if todo.user_id != current_user.id:
        raise HTTPException(
            status_code=403,
            detail="Access denied: you can only access your own todos"
        )


def todo_to_read(todo: Todo) -> TodoRead:
    """Convert Todo model to TodoRead schema with JSON parsing."""
    return TodoRead(
        id=todo.id,
        title=todo.title,
        description=todo.description,
        completed=todo.completed,
        priority=todo.priority,
        due_date=todo.due_date,
        created_at=todo.created_at,
        updated_at=todo.updated_at,
        user_id=todo.user_id,
        tags=json.loads(todo.tags) if isinstance(todo.tags, str) else todo.tags,
        assigned_to=json.loads(todo.assigned_to) if isinstance(todo.assigned_to, str) else todo.assigned_to,
        version=todo.version,
        last_modified_by=todo.last_modified_by,
        recurrence_pattern=todo.recurrence_pattern,
        reminder_enabled=todo.reminder_enabled,
        reminder_offset=todo.reminder_offset,
    )


# ============================================
# TODO ENDPOINTS
# ============================================

@router.get("/api/todos", response_model=list[TodoRead])
def list_todos(
    status: str = Query("all", description="Filter: all, pending, completed"),
    sort: str = Query("created", description="Sort: created, due_date, priority"),
    search: str = Query("", description="Search in title and description"),
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """List all todos for the current user."""
    query = select(Todo).where(Todo.user_id == current_user.id)

    # Filter by status
    if status == "pending":
        query = query.where(Todo.completed == False)  # noqa
    elif status == "completed":
        query = query.where(Todo.completed == True)  # noqa

    # Search
    if search:
        query = query.where(
            (Todo.title.ilike(f"%{search}%")) |
            (Todo.description.ilike(f"%{search}%"))
        )

    # Sort
    if sort == "due_date":
        query = query.order_by(Todo.due_date.asc())
    elif sort == "priority":
        query = query.order_by(Todo.priority.desc())
    else:
        query = query.order_by(Todo.created_at.desc())

    todos = session.exec(query).all()
    return [todo_to_read(todo) for todo in todos]


@router.post("/api/todos", response_model=TodoRead, status_code=201)
def create_todo(
    body: TodoCreate,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Create a new todo."""
    todo = Todo(
        id=str(uuid.uuid4()),
        title=body.title,
        description=body.description,
        priority=body.priority,
        due_date=body.due_date,
        tags=json.dumps(body.tags),
        user_id=current_user.id,
        recurrence_pattern=body.recurrence_pattern,
        reminder_enabled=body.reminder_enabled,
        reminder_offset=body.reminder_offset,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return todo_to_read(todo)


@router.get("/api/todos/{todo_id}", response_model=TodoRead)
def get_todo(
    todo_id: str,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Get a specific todo."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    return todo_to_read(todo)


@router.patch("/api/todos/{todo_id}", response_model=TodoRead)
def update_todo(
    todo_id: str,
    body: TodoUpdate,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Update a todo."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    
    # Update fields
    update_data = body.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        if field == "tags":
            setattr(todo, field, json.dumps(value))
        elif field == "assigned_to":
            setattr(todo, field, json.dumps(value))
        else:
            setattr(todo, field, value)
    
    todo.updated_at = datetime.utcnow()
    todo.version += 1
    todo.last_modified_by = current_user.id
    
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return todo_to_read(todo)


@router.delete("/api/todos/{todo_id}", status_code=204)
def delete_todo(
    todo_id: str,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Delete a todo."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    session.delete(todo)
    session.commit()


@router.patch("/api/todos/{todo_id}/complete", response_model=TodoRead)
def toggle_complete(
    todo_id: str,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Toggle todo completion status."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    
    todo.completed = not todo.completed
    todo.updated_at = datetime.utcnow()
    todo.version += 1
    todo.last_modified_by = current_user.id
    
    session.add(todo)
    session.commit()
    session.refresh(todo)
    return todo_to_read(todo)


# ============================================
# COMMENT ENDPOINTS
# ============================================

def comment_to_read(comment: Comment) -> CommentRead:
    """Convert Comment model to CommentRead schema with JSON parsing."""
    return CommentRead(
        id=comment.id,
        content=comment.content,
        created_at=comment.created_at,
        updated_at=comment.updated_at,
        user_id=comment.user_id,
        todo_id=comment.todo_id,
        mentions=json.loads(comment.mentions) if isinstance(comment.mentions, str) else comment.mentions,
        resolved=comment.resolved,
    )


@router.get("/api/todos/{todo_id}/comments", response_model=list[CommentRead])
def get_comments(
    todo_id: str,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Get all comments for a todo."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    
    comments = session.exec(
        select(Comment).where(Comment.todo_id == todo_id)
    ).all()
    return [comment_to_read(comment) for comment in comments]


@router.post("/api/todos/{todo_id}/comments", response_model=CommentRead, status_code=201)
def create_comment(
    todo_id: str,
    body: CommentCreate,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Add a comment to a todo."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    
    comment = Comment(
        id=str(uuid.uuid4()),
        content=body.content,
        todo_id=todo_id,
        user_id=current_user.id,
        mentions=json.dumps(body.mentions),
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )
    session.add(comment)
    session.commit()
    session.refresh(comment)
    return comment_to_read(comment)


@router.delete("/api/todos/{todo_id}/comments/{comment_id}", status_code=204)
def delete_comment(
    todo_id: str,
    comment_id: str,
    session: Session = Depends(get_session),
    current_user: AuthUser = Depends(get_current_user),
):
    """Delete a comment."""
    todo = get_todo_or_404(todo_id, session)
    verify_todo_ownership(todo, current_user)
    
    comment = session.exec(
        select(Comment).where(Comment.id == comment_id)
    ).first()
    
    if not comment:
        raise HTTPException(status_code=404, detail="Comment not found")
    
    if comment.user_id != current_user.id:
        raise HTTPException(status_code=403, detail="Can only delete your own comments")
    
    session.delete(comment)
    session.commit()


# ============================================
# USER ENDPOINTS
# ============================================

@router.get("/api/users/me", response_model=UserRead)
def get_current_user_info(
    current_user: AuthUser = Depends(get_current_user),
    session: Session = Depends(get_session),
):
    """Get current user information."""
    user = session.exec(
        select(User).where(User.id == current_user.id)
    ).first()
    
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    
    return user
