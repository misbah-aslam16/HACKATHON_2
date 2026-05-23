# 🔧 Fix Backend CORS - Allow Vercel Frontend

Your backend on Railway needs to allow requests from your Vercel frontend. Let's fix the CORS settings.

## 🔍 The Problem

Backend is rejecting requests from Vercel frontend because CORS (Cross-Origin Resource Sharing) is not configured.

**Error in browser console:**
```
Access to XMLHttpRequest at 'https://your-backend.railway.app/...' 
from origin 'https://your-frontend.vercel.app' has been blocked by CORS policy
```

---

## 🔧 Solution: Update Backend CORS

### Step 1: Find Your Backend CORS Configuration

**File:** `backend/main.py`

Look for this section:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[...],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Step 2: Update CORS Settings

Replace the `allow_origins` list with:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        "http://192.168.0.106:3000",
        "http://192.168.0.106:8000",
        "https://your-frontend-xxxxx.vercel.app",  # Add your Vercel URL
        "https://your-backend-xxxxx.railway.app",  # Add your Railway URL
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

### Step 3: Replace Placeholders

Replace these with your actual URLs:
- `https://your-frontend-xxxxx.vercel.app` → Your Vercel frontend URL
- `https://your-backend-xxxxx.railway.app` → Your Railway backend URL

**Example:**
```python
allow_origins=[
    "http://localhost:3000",
    "http://localhost:8000",
    "http://192.168.0.106:3000",
    "http://192.168.0.106:8000",
    "https://todo-app-frontend.vercel.app",
    "https://todo-backend-production.railway.app",
]
```

---

## 📝 Complete Example

Here's the complete CORS configuration:

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        "http://192.168.0.106:3000",
        "http://192.168.0.106:8000",
        "https://your-frontend-xxxxx.vercel.app",  # Your Vercel URL
        "https://your-backend-xxxxx.railway.app",  # Your Railway URL
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Rest of your app...
```

---

## 🚀 Deploy Updated Backend

### Step 1: Commit Changes

```bash
git add backend/main.py
git commit -m "fix: update cors settings for vercel frontend"
git push origin main
```

### Step 2: Railway Auto-Redeploy

1. Go to: https://railway.app
2. Open your backend project
3. Railway will automatically detect the push
4. Wait for deployment to complete

Or manually redeploy:
1. Go to Railway dashboard
2. Click your backend service
3. Click **Deploy** button
4. Wait for deployment

---

## 🧪 Test CORS Fix

After redeploying backend:

1. Open your Vercel frontend
2. Open browser DevTools (F12)
3. Go to **Console** tab
4. Try to create a todo
5. Check for CORS errors

**Expected:**
- No CORS errors
- Request succeeds
- Todo is created

**If still getting CORS error:**
- Verify Vercel URL is correct in CORS settings
- Check backend logs in Railway
- Redeploy backend again

---

## 🔐 Production CORS Settings

For production, you can also allow all origins (not recommended):

```python
allow_origins=["*"]
```

But it's better to be specific:

```python
allow_origins=[
    "https://your-frontend-xxxxx.vercel.app",
    "https://your-backend-xxxxx.railway.app",
]
```

---

## 📋 Checklist

- [ ] Found CORS configuration in `backend/main.py`
- [ ] Added your Vercel frontend URL
- [ ] Added your Railway backend URL
- [ ] Committed changes
- [ ] Pushed to main branch
- [ ] Railway auto-redeployed
- [ ] Tested frontend-backend connection
- [ ] No CORS errors

---

## 🎉 After Fix

Once CORS is fixed:

1. Frontend can make requests to backend
2. Todos can be created/read/updated/deleted
3. Full stack working end-to-end

---

**Status:** Ready to Fix

**Time:** 5 minutes

**Result:** CORS errors gone, frontend-backend connected!

---

**Happy Fixing! 🚀**
