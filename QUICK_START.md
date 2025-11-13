# 🚀 Quick Railway Deployment

## Step 1: Login (Run in Your Terminal)

```bash
railway login
```

Click "Authorize" in the browser that opens.

---

## Step 2: Initialize Project

```bash
cd "/Users/dohoonkim/GauntletAI/Parent Onboarding"
railway init
```

Choose: **Empty Project**, name it `parent-onboarding`

---

## Step 3: Add Databases

```bash
# Add PostgreSQL
railway add --database postgresql

# Add Redis
railway add --database redis
```

---

## Step 4: Deploy Rails API

```bash
cd apps/api
railway up

# After deployment completes, set required environment variables:
railway variables set OPENAI_API_KEY=your-key-here
railway variables set AWS_ACCESS_KEY_ID=your-key-here
railway variables set AWS_SECRET_ACCESS_KEY=your-key-here
railway variables set AWS_S3_BUCKET=your-bucket-name
railway variables set AWS_REGION=us-east-1
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)

# Run migrations
railway run rails db:migrate
```

---

## Step 5: Get API URL

```bash
railway domain
```

Copy the URL (e.g., `https://your-app.railway.app`)

---

## Step 6: Deploy Next.js Web

```bash
cd ../web

# IMPORTANT: Update these with your actual API URL from step 5
railway up

railway variables set NEXT_PUBLIC_GRAPHQL_URL=https://YOUR-API-URL.railway.app/graphql
railway variables set NEXT_PUBLIC_API_URL=https://YOUR-API-URL.railway.app
```

---

## Step 7: Access Your App

```bash
# Get web app URL
railway domain
```

Open the URL in your browser - your app should be live! 🎉

---

## Need Your Environment Variables?

If you haven't gotten these yet, see `ENV_SETUP_GUIDE.md` for detailed instructions on:
- Getting OpenAI API key
- Setting up AWS S3
- Configuring other services

---

## Useful Commands

```bash
# View logs
railway logs

# Check service status  
railway status

# Open Railway dashboard
railway open

# Redeploy
railway up
```

---

## Troubleshooting

**Problem: "Cannot find DATABASE_URL"**
- Solution: Railway auto-sets this when you add PostgreSQL. Make sure you ran `railway add --database postgresql`

**Problem: Build fails**
- Solution: Check logs with `railway logs` and verify all dependencies are in Gemfile/package.json

**Problem: Web app can't connect to API**
- Solution: Make sure `NEXT_PUBLIC_GRAPHQL_URL` is set correctly with your actual API URL

**Problem: CORS errors**
- Solution: API already configured for CORS. Make sure both services are deployed on Railway.

