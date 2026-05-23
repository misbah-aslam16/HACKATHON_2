# Quick Start - Option B Implementation

## Prerequisites
- Python 3.13+
- Node.js 20+
- PostgreSQL (or Neon database)
- Docker & Docker Compose (optional)

## 5-Minute Setup

### Step 1: Setup Backend Environment
```bash
# Copy template
cp backend/.env.local.example backend/.env.local

# Edit backend/.env.local with your database URL
# Example for Neon:
# DATABASE_URL=postgresql://user:password@ep-xxx.neon.tech/todo_db?sslmode=require
# DATABASE_URL_UNPOOLED=postgresql://user:password@ep-xxx.neon.tech/todo_db?sslmode=require
```

### Step 2: Setup Frontend Environment
```bash
# Copy template
cp todo-app-fullstack/.env.local.example todo-app-fullstack/.env.local

# Edit todo-app-fullstack/.env.local with same database URL
```

### Step 3: Install Backend Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### Step 4: Start Backend
```bash
# From backend directory
uvicorn main:app --reload --port 8000
```

Backend will be available at: `http://localhost:8000`
API docs at: `http://localhost:8000/docs`

### Step 5: Install Frontend Dependencies
```bash
cd todo-app-fullstack
npm install
```

### Step 6: Start Frontend
```bash
# From todo-app-fullstack directory
npm run dev
```

Frontend will be available at: `http://localhost:3000`

## Testing the API

### 1. Create User Account
```bash
curl -X POST http://localhost:8000/api/auth/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "password123",
    "name": "Test User"
  }'
```

Response:
```json
{
  "id": "uuid",
  "email": "test@example.com",
  "name": "Test User",
  "avatar_url": null,
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "expires_at": "2026-05-30T10:00:00"
}
```

Save the `token` for next requests.

### 2. Create a Todo
```bash
curl -X POST http://localhost:8000/api/todos \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Buy groceries",
    "description": "Milk, eggs, bread",
    "priority": "high",
    "tags": ["shopping", "urgent"]
  }'
```

### 3. List Todos
```bash
curl -X GET http://localhost:8000/api/todos \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 4. Update Todo
```bash
curl -X PATCH http://localhost:8000/api/todos/TODO_ID \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "completed": true,
    "priority": "medium"
  }'
```

### 5. Add Comment
```bash
curl -X POST http://localhost:8000/api/todos/TODO_ID/comments \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "This is important!",
    "mentions": []
  }'
```

### 6. Get Comments
```bash
curl -X GET http://localhost:8000/api/todos/TODO_ID/comments \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## Using Docker Compose

### Start All Services
```bash
docker-compose up --build
```

Services will be available at:
- Frontend: `http://localhost:3000`
- Backend: `http://localhost:8080` (external) → `8000` (internal)
- API Docs: `http://localhost:8080/docs`

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f backend
docker-compose logs -f frontend
```

### Stop Services
```bash
docker-compose down
```

## Troubleshooting

### Backend won't start
```bash
# Check Python version
python --version  # Should be 3.13+

# Check dependencies
pip list | grep -E "fastapi|sqlmodel|pydantic"

# Check database connection
python -c "from db import engine; print(engine)"
```

### Frontend won't start
```bash
# Clear cache
rm -rf node_modules .next
npm install
npm run dev
```

### Database connection error
```bash
# Test connection
psql "postgresql://user:password@host/db"

# Or for Neon:
psql "postgresql://user:password@ep-xxx.neon.tech/todo_db?sslmode=require"
```

### CORS errors
- Verify backend is running on port 8000
- Check frontend URL in backend CORS config
- Clear browser cache and cookies

### Auth token errors
- Verify token is in Authorization header
- Check token hasn't expired (7 days)
- Verify BETTER_AUTH_SECRET matches

## API Endpoints Reference

### Authentication
- `POST /api/auth/signup` - Create account
- `POST /api/auth/signin` - Login
- `POST /api/auth/signout` - Logout
- `GET /api/auth/session` - Get session
- `POST /api/auth/refresh` - Refresh token

### Todos
- `GET /api/todos` - List todos
- `POST /api/todos` - Create todo
- `GET /api/todos/{id}` - Get todo
- `PATCH /api/todos/{id}` - Update todo
- `DELETE /api/todos/{id}` - Delete todo
- `PATCH /api/todos/{id}/complete` - Toggle complete

### Comments
- `GET /api/todos/{id}/comments` - List comments
- `POST /api/todos/{id}/comments` - Add comment
- `DELETE /api/todos/{id}/comments/{id}` - Delete comment

### Users
- `GET /api/users/me` - Get current user

## Next: Frontend Integration

The frontend should now be able to:
1. Sign up new users
2. Sign in existing users
3. Create, read, update, delete todos
4. Add and view comments
5. Filter and search todos

Check `todo-app-fullstack/lib/api.ts` or similar for frontend API client configuration.

## Support

For issues or questions:
1. Check API docs: `http://localhost:8000/docs`
2. Review logs: `docker-compose logs -f`
3. Check `.env.local` files are properly configured
4. Verify database connection
