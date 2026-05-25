# 🚀 DEPLOY NOW - Step by Step

## What Was Fixed
✅ All Python models now use **snake_case** to match the actual PostgreSQL database schema
✅ No more `RuntimeError: Passing sa_column_kwargs is not supported when also passing a sa_column`
✅ No more `column "user_id" of relation "account" does not exist` errors

## Latest Commit
```
1393250 - fix: revert to snake_case field names to match actual database schema
```

## Deployment Steps

### Step 1: Redeploy Backend on Railway
1. Open: https://railway.app/dashboard
2. Click on your **backend** service
3. Click the **"Deployments"** tab
4. Click the **"Deploy"** button (top right)
5. Wait 5-10 minutes for deployment to complete
6. Check the logs to confirm it started without errors

### Step 2: Test Signup (After Deployment)
Open your browser and go to: https://hackathon-2-tiqg.vercel.app

1. Click "Sign Up"
2. Enter email: `test@example.com`
3. Enter password: `password123`
4. Click "Sign Up"
5. **Expected**: Should redirect to dashboard ✅

### Step 3: Test Signin
1. Click "Sign Out" (if logged in)
2. Click "Sign In"
3. Enter email: `test@example.com`
4. Enter password: `password123`
5. Click "Sign In"
6. **Expected**: Should redirect to dashboard ✅

### Step 4: Verify in Console
Open browser DevTools (F12) → Console tab

**Should NOT see these errors:**
- ❌ `401 Unauthorized` on `/api/auth/get-session`
- ❌ `500 Internal Server Error` on signup
- ❌ `column "user_id" does not exist`

**Should see:**
- ✅ Successful signup response with token
- ✅ Successful signin response with token
- ✅ Successful session retrieval

## If Something Goes Wrong

### Error: Still getting 500 on signup
1. Check Railway logs: https://railway.app/dashboard
2. Look for error messages
3. Common issues:
   - Database connection failed → Check DATABASE_URL_UNPOOLED env var
   - Import error → Check Python syntax (should be fine)
   - Missing env vars → Check BETTER_AUTH_SECRET is set

### Error: Still getting 401 on get-session
1. Make sure you're sending the token in the Authorization header
2. Token should be in format: `Authorization: Bearer <token>`
3. Check that token hasn't expired

### Error: Redirect not working
1. Check frontend logs in browser console
2. Make sure backend is responding with 200 OK
3. Check that AppContext.js has redirect logic

## Quick Test Commands (Local)

If you want to test locally first:

```bash
# Start backend
cd backend
python -m uvicorn main:app --reload

# In another terminal, test signup
curl -X POST http://localhost:8000/api/auth/sign-up/email \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123","name":"Test"}'

# Test signin
curl -X POST http://localhost:8000/api/auth/sign-in/email \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"pass123"}'

# Test get-session (replace TOKEN with actual token from signup)
curl -X GET http://localhost:8000/api/auth/get-session \
  -H "Authorization: Bearer TOKEN"
```

## Summary
- ✅ Code is fixed and pushed to GitHub
- ✅ All models use snake_case (matches DB)
- ✅ No more schema conflicts
- ⏳ **Just need to redeploy on Railway**

**Next Action**: Go to Railway and click "Deploy" button!
