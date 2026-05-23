# 🚀 Fix Vercel Frontend - Connect to Railway Backend NOW

Your backend is running at: `https://hackathon2-production-8e72.up.railway.app`

Now update your Vercel frontend to connect to it.

## ⚡ Quick Fix (5 minutes)

### Step 1: Go to Vercel Dashboard

1. Open: https://vercel.com/dashboard
2. Click your frontend project
3. Click **Settings** → **Environment Variables**

### Step 2: Add/Update These Variables

Copy and paste these exact values:

```
NEXT_PUBLIC_BACKEND_URL=https://hackathon2-production-8e72.up.railway.app
NEXT_PUBLIC_APP_URL=https://your-frontend-xxxxx.vercel.app
DATABASE_URL=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
AUTH_SECRET=dev-better-auth-secret-change-in-production
BETTER_AUTH_SECRET=wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

**Important:** Replace `https://your-frontend-xxxxx.vercel.app` with your actual Vercel frontend URL.

### Step 3: Redeploy Frontend

1. Go to **Deployments** tab
2. Click the **...** menu on latest deployment
3. Click **Redeploy**
4. Wait for deployment to complete

Or push a new commit:
```bash
git add .
git commit -m "fix: connect to railway backend"
git push origin main
```

### Step 4: Test Connection

1. Open your Vercel frontend URL
2. Try to create a todo
3. Check if it works!

---

## 📋 Environment Variables Breakdown

| Variable | Value | Purpose |
|----------|-------|---------|
| `NEXT_PUBLIC_BACKEND_URL` | `https://hackathon2-production-8e72.up.railway.app` | Frontend connects to this backend |
| `NEXT_PUBLIC_APP_URL` | Your Vercel URL | Frontend URL for redirects |
| `DATABASE_URL` | Neon connection string | Database for Prisma |
| `DATABASE_URL_UNPOOLED` | Neon unpooled connection | Database without pooling |
| `AUTH_SECRET` | Secret key | Authentication |
| `BETTER_AUTH_SECRET` | Secret key | Better Auth library |

---

## 🔐 Fix Backend CORS (If Needed)

If you get CORS error in browser console, update backend CORS:

**File:** `backend/main.py`

Find this section:
```python
app.add_middleware(
    CORSMiddleware,
    allow_origins=[...],
```

Update to include your Vercel URL:
```python
allow_origins=[
    "http://localhost:3000",
    "http://localhost:8000",
    "http://192.168.0.106:3000",
    "http://192.168.0.106:8000",
    "https://your-frontend-xxxxx.vercel.app",  # Add your Vercel URL
    "https://hackathon2-production-8e72.up.railway.app",
]
```

Then commit and push:
```bash
git add backend/main.py
git commit -m "fix: add vercel cors"
git push origin main
```

Railway will auto-redeploy.

---

## ✅ Verification

After redeploy, test:

1. **Frontend loads:** ✅
2. **Can create todo:** ✅
3. **Todo appears in list:** ✅
4. **No CORS errors:** ✅
5. **Can delete todo:** ✅

---

## 🎉 Your Live Links

- **Frontend:** https://your-frontend-xxxxx.vercel.app
- **Backend:** https://hackathon2-production-8e72.up.railway.app
- **Backend Docs:** https://hackathon2-production-8e72.up.railway.app/docs
- **Database:** Neon PostgreSQL

---

## 🆘 If Still Not Working

### Check 1: Is backend running?
```bash
curl https://hackathon2-production-8e72.up.railway.app/health
```

Should return: `{"status":"ok"}`

### Check 2: Check browser console
Open DevTools (F12) → Console tab → Look for errors

### Check 3: Check network requests
Open DevTools → Network tab → Try to create todo → Look for requests to backend

### Check 4: Verify environment variables
Go to Vercel → Settings → Environment Variables → Verify all 6 are set

---

**Status:** ✅ Ready to Fix

**Time:** 5 minutes

**Result:** Frontend and backend connected!

---

**Do this now and your app will work! 🚀**
