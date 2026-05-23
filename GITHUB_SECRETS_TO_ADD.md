# 🔐 GitHub Secrets - Copy and Paste

Your GCP infrastructure is set up! Now add these secrets to GitHub.

## 📋 How to Add Secrets

1. Go to: `https://github.com/asma-aslam30/HACKATHON_2/settings/secrets/actions`
2. Click **New repository secret**
3. Copy each secret below and paste into GitHub

---

## 🔑 Secret 1: WIF_PROVIDER

**Name:** `WIF_PROVIDER`

**Value:**
```
projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/github/providers/github
```

Replace `PROJECT_NUMBER` with: `todo-497210` (your project number)

**Full Value:**
```
projects/todo-497210/locations/global/workloadIdentityPools/github/providers/github
```

---

## 🔑 Secret 2: WIF_SERVICE_ACCOUNT

**Name:** `WIF_SERVICE_ACCOUNT`

**Value:**
```
github-actions@todo-497210.iam.gserviceaccount.com
```

---

## 🔑 Secret 3: DATABASE_URL

**Name:** `DATABASE_URL`

**Value:**
```
postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
```

---

## 🔑 Secret 4: DATABASE_URL_UNPOOLED

**Name:** `DATABASE_URL_UNPOOLED`

**Value:**
```
postgresql://neondb_owner:npg_sm7VNYxjK3nU@ep-frosty-mouse-a4hyr3wp.us-east-1.aws.neon.tech/neondb?sslmode=require
```

---

## 🔑 Secret 5: AUTH_SECRET

**Name:** `AUTH_SECRET`

**Value:**
```
dev-better-auth-secret-change-in-production
```

---

## 🔑 Secret 6: BETTER_AUTH_SECRET

**Name:** `BETTER_AUTH_SECRET`

**Value:**
```
wbaQXPKS9uqvAhCmyghy+m4SwjQQEv/3bq8ImBRoAfc=
```

---

## ✅ Verification Checklist

After adding all 6 secrets, verify:

- [ ] WIF_PROVIDER added
- [ ] WIF_SERVICE_ACCOUNT added
- [ ] DATABASE_URL added
- [ ] DATABASE_URL_UNPOOLED added
- [ ] AUTH_SECRET added
- [ ] BETTER_AUTH_SECRET added

---

## 🚀 Next Step: Deploy

Once all secrets are added:

```bash
git add .
git commit -m "feat: deploy with github actions"
git push origin main
```

This will trigger the GitHub Actions workflow automatically!

---

## 📊 What Happens After Push

1. GitHub Actions workflow starts
2. Builds backend Docker image (~5-10 min)
3. Builds frontend Docker image (~5-10 min)
4. Pushes to Artifact Registry (~1-2 min)
5. Deploys backend to Cloud Run (~2-3 min)
6. Deploys frontend to Cloud Run (~2-3 min)
7. Services go live (~15-25 min total)

---

## 🔍 Monitor Deployment

1. Go to: `https://github.com/asma-aslam30/HACKATHON_2/actions`
2. Click **Deploy to Cloud Run** workflow
3. Watch the jobs run in real-time

---

## ✅ Verify Services

After deployment completes:

```bash
# View services
gcloud run services list --region us-central1

# View backend
gcloud run services describe todo-backend --region us-central1

# View frontend
gcloud run services describe todo-frontend --region us-central1
```

---

**Status:** ✅ Ready to Deploy
**Next:** Add secrets and push to main!
