# 🔧 Fix Frontend-Backend Connection (Vercel + Railway)

Your frontend on Vercel can't connect to backend on Railway because the environment variables are wrong. Let's fix it!

## 🔍 The Problem

**Current Frontend Config:**
```
NEXT_PUBLIC_BACKEND_URL=http://192.168.0.106:8000
```

This is a **local IP address** that only works on your home network. Vercel can't access it!

**Solution:** Use your Railway backend URL instead.

---

## 📋 Step 1: Get Your Railway Backend URL

1. Go to: https://railway.app
2. Login to your account
3. Open your backend project
4. Click on the backend service
5. Go to **Settings** tab
6. Look for **Public URL** or **Domain**
7. Copy the URL (should look like: `https://your-backend-xxxxx.railway.app`)

**Example:**
```
https://todo-backend-xxxxx.railway.app
```

---

## 📋 Step 2: Update Vercel Environment Variables

1. Go to: https://vercel.com
2. Login to your account
3. Open your frontend project
4. Click **Settings** → **Environment Variables**
5. Find or create: `NEXT_PUBLIC_BACKEND_URL`
6. Set the value to your Railway backend URL
7. Click **Save**

**Example:**
```
NEXT_PUBLIC_BACKEND_URL=https://todo-backend-xxxxx.railway.app
```

---

## 📋 Step 3: Redeploy Frontend on Vercel

1. Go to your Vercel project
2. Click **Deployments**
3. Find the latest deployment
4. Click the **...** menu
5. Click **Redeploy**
6. Wait for deployment to complete

Or push a new commit to trigger automatic deployment:

```bash
git add .
git commit -m "fix: update backend url for production"
git push origin main
```

---

## 🔐 Step 4: Verify Backend CORS Settings

Your Railway backend needs to allow requests from Vercel. Check your backend code:

**File:** `backend/main.py`

Look for CORS configuration. It should include your Vercel URL:

```python
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://localhost:8000",
        "https://your-frontend-xxxxx.vercel.app",  # Add your Vercel URL
        "*"  # Or allow all (not recommended for production)
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```

If you need to update CORS:

1. Edit `backend/main.py`
2. Add your Vercel frontend URL to `allow_origins`
3. Commit and push to Railway
4. Railway will auto-redeploy

---

## 📝 Environment Variables Checklist

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

```
DATABASE_URL=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
PORT=8000
```

---

## 🧪 Test the Connection

After updating and redeploying:

1. Open your Vercel frontend URL
2. Open browser DevTools (F12)
3. Go to **Network** tab
4. Try to create a todo
5. Check if requests go to your Railway backend URL
6. Look for any CORS errors

**Expected:**
- Requests should go to `https://your-backend-xxxxx.railway.app`
- Status should be 200 (success)
- No CORS errors

**If CORS error:**
- Update backend CORS settings
- Redeploy backend
- Try again

---

## 🔗 Quick Links

- **Vercel Dashboard:** https://vercel.com/dashboard
- **Railway Dashboard:** https://railway.app
- **Your Frontend:** https://your-frontend-xxxxx.vercel.app
- **Your Backend:** https://your-backend-xxxxx.railway.app

---

## 📋 Troubleshooting

### Frontend shows "Cannot connect to backend"

**Solution:**
1. Check `NEXT_PUBLIC_BACKEND_URL` in Vercel environment variables
2. Verify it's the correct Railway URL
3. Redeploy frontend
4. Check browser console for errors

### CORS error in browser console

**Solution:**
1. Update backend CORS settings in `backend/main.py`
2. Add your Vercel URL to `allow_origins`
3. Commit and push to Railway
4. Wait for auto-redeploy
5. Refresh frontend

### Backend returns 404 or 500 error

**Solution:**
1. Check Railway backend logs
2. Verify database connection
3. Check environment variables in Railway
4. Redeploy backend

### Network request shows 0 bytes response

**Solution:**
1. Check if backend is running
2. Verify backend URL is correct
3. Check CORS settings
4. Check firewall/network settings

---

## ✅ Verification Checklist

- [ ] Got Railway backend URL
- [ ] Updated Vercel environment variables
- [ ] Redeployed frontend on Vercel
- [ ] Updated backend CORS settings (if needed)
- [ ] Redeployed backend on Railway
- [ ] Tested frontend-backend connection
- [ ] No CORS errors in console
- [ ] Todos can be created/read/updated/deleted

---

## 🎉 After Fix

Once everything is connected:

1. **Frontend URL:** https://your-frontend-xxxxx.vercel.app
2. **Backend URL:** https://your-backend-xxxxx.railway.app
3. **Database:** Neon PostgreSQL (already configured)
4. **Full stack working:** ✅

---

**Status:** Ready to Fix

**Time to Fix:** 5-10 minutes

**Result:** Frontend and backend connected and working!

---

**Happy Fixing! 🚀**
