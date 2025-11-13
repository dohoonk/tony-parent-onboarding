# 🎯 Manual Railway Deployment Guide

## Prerequisites
- ✅ Railway CLI installed
- ✅ Logged in (`railway login`)
- ✅ Project created (`parent-onboarding`)

---

## Step 1: Deploy Rails API

### 1.1 Navigate to API directory
```bash
cd "/Users/dohoonkim/GauntletAI/Parent Onboarding/apps/api"
```

### 1.2 Deploy the service
```bash
railway up
```

Railway will:
- Detect the Dockerfile
- Build the Rails application
- Deploy it to a new service
- This takes 2-5 minutes

### 1.3 Set Environment Variables

After deployment completes, set these variables:

```bash
# Required for AI features
railway variables set OPENAI_API_KEY=sk-your-actual-openai-key-here

# Required for insurance card uploads
railway variables set AWS_ACCESS_KEY_ID=AKIA...your-key
railway variables set AWS_SECRET_ACCESS_KEY=wJal...your-secret
railway variables set AWS_S3_BUCKET=your-bucket-name
railway variables set AWS_REGION=us-east-1

# Rails security
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)

# Rails configuration
railway variables set RAILS_ENV=production
railway variables set RAILS_SERVE_STATIC_FILES=true
railway variables set RAILS_LOG_TO_STDOUT=true
```

**Note:** DATABASE_URL and REDIS_URL are automatically set by Railway when you added the databases!

### 1.4 Run Database Migrations
```bash
railway run rails db:migrate
```

### 1.5 Generate Domain (Get API URL)
```bash
railway domain
```

**Copy this URL!** You'll need it for the web app.

Example output: `api-production-xxxx.up.railway.app`

---

## Step 2: Deploy Next.js Web App

### 2.1 Navigate to Web directory
```bash
cd ../web
# OR
cd "/Users/dohoonkim/GauntletAI/Parent Onboarding/apps/web"
```

### 2.2 Deploy the service
```bash
railway up
```

Railway will:
- Detect the Dockerfile
- Build the Next.js application
- Deploy it to a new service
- This takes 2-5 minutes

### 2.3 Set Environment Variables

**IMPORTANT:** Replace `YOUR-API-URL` with the URL from Step 1.5!

```bash
# Replace YOUR-API-URL with actual URL from step 1.5
railway variables set NEXT_PUBLIC_GRAPHQL_URL=https://YOUR-API-URL.up.railway.app/graphql
railway variables set NEXT_PUBLIC_API_URL=https://YOUR-API-URL.up.railway.app

# Production mode
railway variables set NODE_ENV=production
```

**Example:**
```bash
railway variables set NEXT_PUBLIC_GRAPHQL_URL=https://api-production-xxxx.up.railway.app/graphql
railway variables set NEXT_PUBLIC_API_URL=https://api-production-xxxx.up.railway.app
railway variables set NODE_ENV=production
```

### 2.4 Generate Domain (Get Web URL)
```bash
railway domain
```

Example output: `web-production-yyyy.up.railway.app`

---

## Step 3: Access Your Application

Open your browser and go to:
```
https://your-web-url.up.railway.app
```

Test:
- ✅ Page loads
- ✅ Can start onboarding
- ✅ AI chat works (requires OpenAI key)
- ✅ No CORS errors in console

---

## Useful Commands

### View logs
```bash
# API logs
cd apps/api
railway logs

# Web logs
cd apps/web
railway logs
```

### Check service status
```bash
railway status
```

### Open Railway dashboard
```bash
railway open
```

### Redeploy after code changes
```bash
railway up
```

### Run Rails console
```bash
cd apps/api
railway run rails console
```

### Run database commands
```bash
cd apps/api
railway run rails db:seed
railway run rails db:rollback
```

---

## Alternative: Use Railway Dashboard

If CLI is giving issues, you can do everything in the web dashboard:

### 1. Go to Railway Dashboard
```bash
railway open
```

### 2. Deploy from GitHub (Easier!)
1. Click "New Service"
2. Select "GitHub Repo"
3. Connect your repository
4. Set root directory to `apps/api` (for API) or `apps/web` (for web)
5. Railway auto-detects Dockerfile
6. Click "Deploy"

### 3. Set Variables in Dashboard
1. Click on your service
2. Go to "Variables" tab
3. Click "Add Variable"
4. Add each environment variable
5. Service auto-redeploys

---

## Troubleshooting

### "Multiple services found"
Solution: Specify which service you're working on by navigating to its directory first.

### "Cannot connect to database"
Solution: Make sure PostgreSQL was added with `railway add --database postgres`

### Build fails
Solution: Check logs with `railway logs` and verify Dockerfile syntax.

### Web can't connect to API
Solution: 
1. Verify API URL is correct: `cd apps/api && railway domain`
2. Check environment variables: `cd apps/web && railway variables`
3. Make sure CORS is enabled (already done in your code)

### CORS errors
Solution: Already configured! Check that both services are on Railway domains.

---

## Cost Tracking

Check usage:
```bash
railway open
```
Go to "Usage" tab to see current spend.

Estimated: ~$20-25/month with $5 credit.

---

## Need to Start Over?

Delete project:
```bash
railway open
```
Settings → Delete Project

Then run through this guide again!

