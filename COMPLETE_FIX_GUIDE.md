# 🔧 Complete Fix Guide - Frontend & Backend Connection

Your frontend on Vercel and backend on Railway aren't connected. Follow this guide to fix it completely.

## 🎯 The Problem

1. **Frontend** (Vercel) has wrong backend URL → Points to local IP `192.168.0.106:8000`
2. **Backend** (Railway) CORS not configured → Rejects requests from Vercel
3. **Result:** Frontend can't connect to backend

## ✅ The Solution

Fix both frontend and backend configurations.

---

## 📋 Step-by-Step Fix

### STEP 1: Get Your URLs (5 minutes)

#### Get Railway Backend URL

1. Go to: https://railway.app
2. Login
3. Open your backend project
4. Click the backend service
5. Go to **Settings** tab
6. Find **Public URL** or **Domain**
7. Copy the URL

**Example:** `https://todo-backend-production.railway.app`

#### Get Vercel Frontend URL

1. Go to: https://vercel.com/dashboard
2. Click your frontend project
3. Copy the URL from the top

**Example:** `https://todo-app-frontend.vercel.app`

---

### STEP 2: Fix Frontend Environment Variables (5 minutes)

1. Go to: https://vercel.com/dashboard
2. Click your frontend project
3. Click **Settings** → **Environment Variables**
4. Update or add these variables:

| Name | Value |
|------|-------|
| `NEXT_PUBLIC_BACKEND_URL` | Your Railway backend URL |
| `NEXT_PUBLIC_APP_URL` | Your Vercel frontend URL |
| `DATABASE_URL` | `postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require` |
| `DATABASE_URL_UNPOOLED` | `postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require` |
| `AUTH_SECRET` | `dev-better-auth-secret-change-in-production` |
| `BETTER_AUTH_SECRET` | `wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=` |

**Example:**
```
NEXT_PUBLIC_BACKEND_URL=https://todo-backend-production.railway.app
NEXT_PUBLIC_APP_URL=https://todo-app-frontend.vercel.app
```

5. Click **Save**
6. Go to **Deployments**
7. Click **Redeploy** on latest deployment
8. Wait for deployment to complete

---

### STEP 3: Fix Backend CORS Settings (5 minutes)

1. Open `backend/main.py` in your editor
2. Find the CORS configuration (look for `CORSMiddleware`)
3. Update `allow_origins` to include your Vercel URL:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        "http://192.168.0.106:3000",
        "http://192.168.0.106:8000",
        "https://todo-app-frontend.vercel.app",  # Add your Vercel URL
        "https://todo-backend-production.railway.app",  # Add your Railway URL
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

4. Replace with your actual URLs
5. Save the file
6. Commit and push:

```bash
git add backend/main.py
git commit -m "fix: update cors for vercel frontend"
git push origin main
```

7. Railway will auto-redeploy
8. Wait for deployment to complete

---

### STEP 4: Test the Connection (5 minutes)

1. Open your Vercel frontend URL in browser
2. Open DevTools (F12)
3. Go to **Console** tab
4. Try to create a todo
5. Check for errors

**Expected:**
- No CORS errors
- Todo is created successfully
- Data appears in the list

**If CORS error:**
- Verify Vercel URL in backend CORS settings
- Redeploy backend
- Try again

---

## 📊 Configuration Summary

### Frontend (Vercel)

```
NEXT_PUBLIC_BACKEND_URL=https://your-backend-xxxxx.railway.app
NEXT_PUBLIC_APP_URL=https://your-frontend-xxxxx.vercel.app
DATABASE_URL=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
AUTH_SECRET=dev-better-auth-secret-change-in-production
BETTER_AUTH_SECRET=wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

### Backend (Railway)

```python
allow_origins=[
    "http://localhost:3000",
    "http://localhost:8000",
    "http://192.168.0.106:3000",
    "http://192.168.0.106:8000",
    "https://your-frontend-xxxxx.vercel.app",
    "https://your-backend-xxxxx.railway.app",
]
```

---

## 🆘 Troubleshooting

### Frontend shows "Cannot connect to backend"

**Check:**
1. Is `NEXT_PUBLIC_BACKEND_URL` correct in Vercel?
2. Is Railway backend running?
3. Is the URL accessible in browser?

**Fix:**
1. Verify Railway URL
2. Update Vercel environment variable
3. Redeploy frontend

### CORS error in console

**Check:**
1. Is your Vercel URL in backend CORS settings?
2. Did you redeploy backend after updating CORS?

**Fix:**
1. Add Vercel URL to backend CORS
2. Commit and push
3. Wait for Railway to redeploy
4. Refresh frontend

### 404 or 500 error from backend

**Check:**
1. Is backend running on Railway?
2. Are environment variables set in Railway?
3. Is database connection working?

**Fix:**
1. Check Railway logs
2. Verify database connection
3. Redeploy backend

### Network request shows 0 bytes

**Check:**
1. Is backend URL correct?
2. Is CORS configured?
3. Is backend responding?

**Fix:**
1. Test backend URL in browser
2. Check CORS settings
3. Check Railway logs

---

## ✅ Verification Checklist

- [ ] Got Railway backend URL
- [ ] Got Vercel frontend URL
- [ ] Updated Vercel environment variables (6 total)
- [ ] Redeployed frontend on Vercel
- [ ] Updated backend CORS settings
- [ ] Committed and pushed backend changes
- [ ] Railway auto-redeployed backend
- [ ] Tested frontend-backend connection
- [ ] No CORS errors in console
- [ ] Can create/read/update/delete todos

---

## 🎉 After Fix

Once everything is connected:

1. **Frontend:** https://your-frontend-xxxxx.vercel.app
2. **Backend:** https://your-backend-xxxxx.railway.app
3. **Database:** Neon PostgreSQL
4. **Status:** ✅ Fully working

---

## 📞 Quick Links

- **Vercel Dashboard:** https://vercel.com/dashboard
- **Railway Dashboard:** https://railway.app
- **Neon Console:** https://console.neon.tech

---

## 🚀 Summary

| Step | Action | Time |
|------|--------|------|
| 1 | Get URLs | 5 min |
| 2 | Fix frontend env vars | 5 min |
| 3 | Fix backend CORS | 5 min |
| 4 | Test connection | 5 min |
| **Total** | **Complete fix** | **20 min** |

---

**Status:** Ready to Fix

**Time:** 20 minutes

**Result:** Frontend and backend fully connected!

---

**Happy Fixing! 🚀**
