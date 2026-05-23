# 🚀 Deploy Frontend to Vercel Using GitHub Actions

Automatically deploy your frontend to Vercel on every push to main branch.

## 📋 Prerequisites

1. **Vercel Account** - https://vercel.com
2. **Frontend Project on Vercel** - Already deployed
3. **GitHub Repository** - This repo
4. **Vercel CLI Token** - We'll get this

---

## 🔧 Step 1: Get Vercel Tokens

### Get VERCEL_TOKEN

1. Go to: https://vercel.com/account/tokens
2. Click **Create Token**
3. Name it: `github-actions`
4. Copy the token

### Get VERCEL_ORG_ID and VERCEL_PROJECT_ID

1. Go to your Vercel project
2. Click **Settings**
3. Look for **Project ID** - Copy it
4. Look for **Team ID** (if in organization) or use your account ID

Or run this command in your project:
```bash
cd todo-app-fullstack
vercel link
```

This will create `.vercel/project.json` with the IDs.

---

## 🔐 Step 2: Add GitHub Secrets

1. Go to: https://github.com/asma-aslam30/HACKATHON_2/settings/secrets/actions
2. Click **New repository secret**
3. Add these secrets:

### Secret 1: VERCEL_TOKEN
```
Name: VERCEL_TOKEN
Value: (Your Vercel token from Step 1)
```

### Secret 2: VERCEL_ORG_ID
```
Name: VERCEL_ORG_ID
Value: (Your Vercel Organization/Team ID)
```

### Secret 3: VERCEL_PROJECT_ID
```
Name: VERCEL_PROJECT_ID
Value: (Your Vercel Project ID)
```

### Secret 4: VERCEL_PROJECT_NAME
```
Name: VERCEL_PROJECT_NAME
Value: (Your Vercel project name, e.g., "todo-app-frontend")
```

### Secret 5: DATABASE_URL
```
Name: DATABASE_URL
Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### Secret 6: DATABASE_URL_UNPOOLED
```
Name: DATABASE_URL_UNPOOLED
Value: postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
```

### Secret 7: AUTH_SECRET
```
Name: AUTH_SECRET
Value: dev-better-auth-secret-change-in-production
```

### Secret 8: BETTER_AUTH_SECRET
```
Name: BETTER_AUTH_SECRET
Value: wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

---

## 📝 Step 3: Verify Workflow File

The workflow file is already created at:
```
.github/workflows/deploy-frontend-vercel.yml
```

It will:
- Deploy to Vercel on push to main
- Set all environment variables
- Connect to Railway backend: `https://hackathon2-production-8e72.up.railway.app`
- Create deployment summary

---

## 🚀 Step 4: Deploy

### Option A: Push to Main Branch

```bash
git add .
git commit -m "feat: setup github actions vercel deployment"
git push origin main
```

### Option B: Manual Trigger

1. Go to: https://github.com/asma-aslam30/HACKATHON_2/actions
2. Click **Deploy Frontend to Vercel** workflow
3. Click **Run workflow**
4. Select branch: `main`
5. Click **Run workflow**

---

## 📊 What Happens

```
1. Push to main branch
   ↓
2. GitHub Actions triggered
   ├─ Install Vercel CLI
   ├─ Set environment variables
   │  ├─ NEXT_PUBLIC_BACKEND_URL=https://hackathon2-production-8e72.up.railway.app
   │  ├─ DATABASE_URL=...
   │  └─ Other secrets
   ├─ Deploy to Vercel (production)
   └─ Create deployment summary
   ↓
3. Frontend live on Vercel
   ├─ Connected to Railway backend
   ├─ All environment variables set
   └─ Ready to use
```

---

## 🔍 Monitor Deployment

### In GitHub Actions

1. Go to: https://github.com/asma-aslam30/HACKATHON_2/actions
2. Click **Deploy Frontend to Vercel** workflow
3. View the latest run
4. Check logs for any errors

### In Vercel

1. Go to: https://vercel.com/dashboard
2. Click your frontend project
3. View **Deployments** tab
4. Check the latest deployment

---

## ✅ Verify Deployment

After deployment completes:

1. **Frontend loads:** Open your Vercel URL
2. **Backend connected:** Try to create a todo
3. **No errors:** Check browser console (F12)
4. **Full functionality:** Create, read, update, delete todos

---

## 🆘 Troubleshooting

### Workflow fails with "Permission denied"

**Solution:**
1. Verify VERCEL_TOKEN is correct
2. Verify VERCEL_ORG_ID is correct
3. Verify VERCEL_PROJECT_ID is correct
4. Regenerate token if needed

### Workflow fails with "Project not found"

**Solution:**
1. Verify VERCEL_PROJECT_ID is correct
2. Verify VERCEL_ORG_ID is correct
3. Check project exists in Vercel

### Frontend doesn't connect to backend

**Solution:**
1. Verify NEXT_PUBLIC_BACKEND_URL is set correctly
2. Check backend is running: https://hackathon2-production-8e72.up.railway.app/health
3. Check CORS settings in backend

### CORS error in browser console

**Solution:**
1. Update backend CORS settings
2. Add your Vercel URL to allowed origins
3. Redeploy backend

---

## 📋 Environment Variables Set by Workflow

| Variable | Value |
|----------|-------|
| `NEXT_PUBLIC_BACKEND_URL` | `https://hackathon2-production-8e72.up.railway.app` |
| `NEXT_PUBLIC_APP_URL` | Your Vercel URL |
| `DATABASE_URL` | Neon connection string |
| `DATABASE_URL_UNPOOLED` | Neon unpooled connection |
| `AUTH_SECRET` | Auth secret |
| `BETTER_AUTH_SECRET` | Better Auth secret |

---

## 🎉 After Setup

Every time you push to main:

1. ✅ GitHub Actions runs automatically
2. ✅ Frontend deployed to Vercel
3. ✅ Environment variables set
4. ✅ Connected to Railway backend
5. ✅ Live and working!

---

## 📞 Quick Links

- **GitHub Actions:** https://github.com/asma-aslam30/HACKATHON_2/actions
- **Vercel Dashboard:** https://vercel.com/dashboard
- **Railway Backend:** https://hackathon2-production-8e72.up.railway.app
- **Backend Docs:** https://hackathon2-production-8e72.up.railway.app/docs

---

## ✅ Checklist

- [ ] Got Vercel tokens
- [ ] Added all 8 GitHub secrets
- [ ] Verified workflow file exists
- [ ] Pushed to main branch
- [ ] Workflow ran successfully
- [ ] Frontend deployed to Vercel
- [ ] Frontend connects to backend
- [ ] No errors in console

---

**Status:** ✅ Ready to Deploy

**Time:** 5 minutes setup + automatic deployment

**Result:** Frontend automatically deployed to Vercel on every push!

---

**Happy Deploying! 🚀**
