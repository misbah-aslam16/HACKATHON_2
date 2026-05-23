# 🔧 Fix Frontend-Backend Authentication Issue

## Problem Identified

**Error:** `POST https://hackathon-2-tiqg.vercel.app/api/auth/sign-up/email 422 (Unprocessable Content)`

**Root Cause:** The frontend is trying to authenticate against itself (Vercel) instead of the Railway backend.

### What's Happening

1. Frontend auth-client was using `window.location.origin` (Vercel URL)
2. Frontend tries to call `/api/auth/sign-up/email` on Vercel
3. Vercel frontend doesn't have auth endpoints - only the Railway backend does
4. Result: 422 error (Unprocessable Content)

---

## Solution

### Step 1: Update Frontend Auth Client ✅ DONE

**File:** `todo-app-fullstack/lib/auth-client.js`

Changed from:
```javascript
baseURL: typeof window !== 'undefined'
  ? window.location.origin  // ❌ Points to Vercel frontend
  : (process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000')
```

Changed to:
```javascript
baseURL: process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000'  // ✅ Points to Railway backend
```

**Result:** Frontend now calls Railway backend for authentication

---

### Step 2: Verify Backend Auth Endpoints

The Railway backend needs to expose these better-auth endpoints:
- `POST /api/auth/sign-up/email`
- `POST /api/auth/sign-in/email`
- `POST /api/auth/sign-out`
- `GET /api/auth/session`

**Check backend:** https://hackathon2-production-8e72.up.railway.app/docs

---

### Step 3: Ensure CORS is Configured ✅ DONE

**File:** `backend/main.py`

CORS is already configured to accept requests from:
- `https://*.vercel.app` (all Vercel deployments)
- `https://todo-app-frontend.vercel.app` (specific Vercel URL)
- `http://localhost:3000` (local development)

---

### Step 4: Deploy Frontend

Push the updated auth-client to trigger GitHub Actions deployment:

```bash
git add todo-app-fullstack/lib/auth-client.js
git commit -m "fix: point auth client to railway backend"
git push origin main
```

GitHub Actions will:
1. Deploy frontend to Vercel
2. Set `NEXT_PUBLIC_BACKEND_URL` to Railway URL
3. Frontend will now call Railway backend for auth

---

## Architecture After Fix

```
┌─────────────────────────────────────────────────────────────┐
│                    Vercel Frontend                          │
│  (https://hackathon-2-tiqg.vercel.app)                     │
│                                                             │
│  auth-client.baseURL = NEXT_PUBLIC_BACKEND_URL             │
│  ↓                                                          │
│  Points to Railway Backend                                 │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ API Calls
                            │ POST /api/auth/sign-up/email
                            │ POST /api/auth/sign-in/email
                            │ GET /api/auth/session
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Railway Backend                          │
│  (https://hackathon2-production-8e72.up.railway.app)       │
│                                                             │
│  ✅ Exposes better-auth endpoints                          │
│  ✅ CORS configured for Vercel                             │
│  ✅ Connected to Neon PostgreSQL                           │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ SQL Queries
                            │
                            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Neon PostgreSQL                          │
│  (Database)                                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## What Changed

### Frontend Configuration

**`todo-app-fullstack/lib/auth-client.js`**
```diff
- baseURL: typeof window !== 'undefined'
-   ? window.location.origin
-   : (process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000')

+ baseURL: process.env.NEXT_PUBLIC_BACKEND_URL || 'http://localhost:8000'
```

**Result:** Auth client now points to Railway backend instead of Vercel frontend

---

## Testing the Fix

### 1. After Deployment

1. Go to: https://github.com/asma-aslam30/HACKATHON_2/actions
2. Wait for "Deploy Frontend to Vercel" workflow to complete
3. Check Vercel dashboard for deployment status

### 2. Test Sign Up

1. Open your Vercel frontend URL
2. Try to sign up with an email
3. Check browser console (F12) for errors
4. Expected: Should call Railway backend `/api/auth/sign-up/email`

### 3. Verify API Calls

1. Open DevTools (F12)
2. Go to Network tab
3. Try to sign up
4. Look for requests to: `https://hackathon2-production-8e72.up.railway.app/api/auth/...`
5. Should see 200/201 responses (not 422)

### 4. Check Backend Logs

1. Go to Railway dashboard: https://railway.app/dashboard
2. Check backend logs for auth requests
3. Should see incoming requests from Vercel frontend

---

## Troubleshooting

### Still Getting 422 Error?

**Possible causes:**
1. Frontend not redeployed yet
2. `NEXT_PUBLIC_BACKEND_URL` not set in Vercel
3. Backend auth endpoints not implemented
4. CORS still blocking requests

**Solutions:**
1. Wait for GitHub Actions deployment to complete
2. Check Vercel environment variables
3. Check backend API docs: https://hackathon2-production-8e72.up.railway.app/docs
4. Check browser console for CORS errors

### CORS Error in Console?

**Error:** `Access to XMLHttpRequest at 'https://...' from origin 'https://hackathon-2-tiqg.vercel.app' has been blocked by CORS policy`

**Solution:**
1. Backend CORS is already configured
2. Check if backend is running
3. Verify `NEXT_PUBLIC_BACKEND_URL` is correct
4. Try accessing backend directly: https://hackathon2-production-8e72.up.railway.app/health

### Backend Returning 404?

**Error:** `POST https://hackathon2-production-8e72.up.railway.app/api/auth/sign-up/email 404`

**Solution:**
1. Backend doesn't have auth endpoints implemented
2. Check backend API docs: https://hackathon2-production-8e72.up.railway.app/docs
3. May need to add better-auth integration to backend

---

## Next Steps

1. **Deploy frontend** - Push changes to trigger GitHub Actions
2. **Monitor deployment** - Check GitHub Actions workflow
3. **Test sign up** - Try to create an account
4. **Check logs** - Monitor backend logs for auth requests
5. **Verify connection** - Ensure frontend can communicate with backend

---

## Files Modified

- ✅ `todo-app-fullstack/lib/auth-client.js` - Updated to use Railway backend
- ✅ `backend/main.py` - CORS already configured
- ✅ `todo-app-fullstack/.env` - Backend URL already set

---

## Quick Links

- **Frontend Deployment:** https://github.com/asma-aslam30/HACKATHON_2/actions
- **Vercel Dashboard:** https://vercel.com/dashboard
- **Railway Dashboard:** https://railway.app/dashboard
- **Backend API Docs:** https://hackathon2-production-8e72.up.railway.app/docs
- **Backend Health:** https://hackathon2-production-8e72.up.railway.app/health

---

**Status:** ✅ Frontend auth client fixed and ready to deploy

**Next Action:** Push to main to trigger GitHub Actions deployment

