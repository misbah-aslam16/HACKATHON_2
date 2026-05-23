# ⚡ Quick Setup - GitHub Actions → Vercel Deployment

Deploy frontend to Vercel automatically using GitHub Actions. Takes 5 minutes!

## 🎯 What You'll Get

- ✅ Automatic frontend deployment on every push to main
- ✅ Connected to Railway backend: `https://hackathon2-production-8e72.up.railway.app`
- ✅ All environment variables set automatically
- ✅ Full stack working end-to-end

---

## 📋 5-Minute Setup

### Step 1: Get Vercel Tokens (2 minutes)

**Get VERCEL_TOKEN:**
1. Go to: https://vercel.com/account/tokens
2. Click **Create Token**
3. Copy the token

**Get VERCEL_PROJECT_ID and VERCEL_ORG_ID:**
1. Go to your Vercel project
2. Click **Settings**
3. Copy **Project ID**
4. Copy **Team ID** (or your account ID)

Or run:
```bash
cd todo-app-fullstack
vercel link
```

### Step 2: Add GitHub Secrets (3 minutes)

Go to: https://github.com/asma-aslam30/HACKATHON_2/settings/secrets/actions

Add these 8 secrets:

```
1. VERCEL_TOKEN = (Your Vercel token)
2. VERCEL_ORG_ID = (Your Vercel Org/Team ID)
3. VERCEL_PROJECT_ID = (Your Vercel Project ID)
4. VERCEL_PROJECT_NAME = (Your project name, e.g., "todo-app-frontend")
5. DATABASE_URL = postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
6. DATABASE_URL_UNPOOLED = postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
7. AUTH_SECRET = dev-better-auth-secret-change-in-production
8. BETTER_AUTH_SECRET = wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

---

## 🚀 Deploy

Push to main branch:

```bash
git add .
git commit -m "feat: setup github actions vercel deployment"
git push origin main
```

GitHub Actions will automatically:
1. Deploy frontend to Vercel
2. Set all environment variables
3. Connect to Railway backend
4. Go live!

---

## 📊 Monitor

1. Go to: https://github.com/asma-aslam30/HACKATHON_2/actions
2. Click **Deploy Frontend to Vercel** workflow
3. Watch the deployment
4. Check Vercel dashboard for live URL

---

## ✅ Verify

After deployment:

1. Open your Vercel frontend URL
2. Try to create a todo
3. Check if it works!

---

## 🎉 Your Stack

- **Frontend:** Vercel (auto-deployed via GitHub Actions)
- **Backend:** Railway (https://hackathon2-production-8e72.up.railway.app)
- **Database:** Neon PostgreSQL
- **Status:** ✅ Fully connected and working!

---

**Read:** `GITHUB_ACTIONS_VERCEL_DEPLOY.md` for detailed setup

**Do this now and your app will be live! 🚀**
