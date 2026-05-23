# 🔧 Vercel Environment Variables - Copy These

Copy these environment variables to your Vercel project to fix the frontend-backend connection.

## 📋 How to Add to Vercel

1. Go to: https://vercel.com/dashboard
2. Click your frontend project
3. Click **Settings** → **Environment Variables**
4. For each variable below:
   - Click **Add New**
   - Paste the name and value
   - Click **Save**

---

## 🔑 Environment Variables

### 1. NEXT_PUBLIC_BACKEND_URL

**Name:** `NEXT_PUBLIC_BACKEND_URL`

**Value:** (Replace with your Railway backend URL)
```
https://your-backend-xxxxx.railway.app
```

**Example:**
```
https://todo-backend-production.railway.app
```

---

### 2. NEXT_PUBLIC_APP_URL

**Name:** `NEXT_PUBLIC_APP_URL`

**Value:** (Your Vercel frontend URL)
```
https://your-frontend-xxxxx.vercel.app
```

**Example:**
```
https://todo-app-frontend.vercel.app
```

---

### 3. DATABASE_URL

**Name:** `DATABASE_URL`

**Value:**
```
postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
```

---

### 4. DATABASE_URL_UNPOOLED

**Name:** `DATABASE_URL_UNPOOLED`

**Value:**
```
postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
```

---

### 5. AUTH_SECRET

**Name:** `AUTH_SECRET`

**Value:**
```
dev-better-auth-secret-change-in-production
```

---

### 6. BETTER_AUTH_SECRET

**Name:** `BETTER_AUTH_SECRET`

**Value:**
```
wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

---

## ✅ After Adding Variables

1. All 6 variables should be added
2. Click **Redeploy** on your latest deployment
3. Wait for deployment to complete
4. Test the frontend-backend connection

---

## 🔍 Find Your URLs

### Railway Backend URL

1. Go to: https://railway.app
2. Open your backend project
3. Click the backend service
4. Go to **Settings**
5. Look for **Public URL** or **Domain**
6. Copy the URL

**Format:** `https://your-backend-xxxxx.railway.app`

### Vercel Frontend URL

1. Go to: https://vercel.com/dashboard
2. Click your frontend project
3. Look at the top - it shows your URL

**Format:** `https://your-frontend-xxxxx.vercel.app`

---

## 🎯 Quick Copy-Paste

Replace these placeholders:
- `YOUR_BACKEND_URL` → Your Railway backend URL
- `YOUR_FRONTEND_URL` → Your Vercel frontend URL

```
NEXT_PUBLIC_BACKEND_URL=YOUR_BACKEND_URL
NEXT_PUBLIC_APP_URL=YOUR_FRONTEND_URL
DATABASE_URL=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
DATABASE_URL_UNPOOLED=postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
AUTH_SECRET=dev-better-auth-secret-change-in-production
BETTER_AUTH_SECRET=wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

---

## 🚀 After Redeploy

1. Open your Vercel frontend URL
2. Try to create a todo
3. Check if it works
4. If CORS error, update backend CORS settings

---

**Status:** Ready to Configure

**Time:** 5 minutes

**Result:** Frontend and backend connected!
