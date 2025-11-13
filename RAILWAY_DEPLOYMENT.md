# Railway Deployment Guide

## Step 1: Login to Railway

```bash
railway login
```

This will open your browser. Click "Authorize" to login.

---

## Step 2: Create New Project

```bash
cd "/Users/dohoonkim/GauntletAI/Parent Onboarding"
railway init
```

- Choose: **Empty Project**
- Name it: `parent-onboarding` (or your preference)

---

## Step 3: Add PostgreSQL Database

```bash
railway add --database postgresql
```

This creates a managed PostgreSQL database.

---

## Step 4: Add Redis Database

```bash
railway add --database redis
```

This creates a managed Redis instance.

---

## Step 5: Deploy Rails API

```bash
cd apps/api
railway up
```

Railway will detect the Dockerfile and deploy automatically.

After deployment, get the service name:
```bash
railway status
```

Set environment variables for the API:
```bash
railway variables set RAILS_ENV=production
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)
railway variables set RAILS_SERVE_STATIC_FILES=true
railway variables set RAILS_LOG_TO_STDOUT=true

# OpenAI (required for AI features)
railway variables set OPENAI_API_KEY=your-openai-key-here

# AWS S3 (required for insurance card uploads)
railway variables set AWS_ACCESS_KEY_ID=your-aws-key-here
railway variables set AWS_SECRET_ACCESS_KEY=your-aws-secret-here
railway variables set AWS_S3_BUCKET=your-bucket-name
railway variables set AWS_REGION=us-east-1
```

The DATABASE_URL and REDIS_URL will be automatically set by Railway!

---

## Step 6: Deploy Sidekiq Worker

Railway doesn't support multiple services from the same code easily, so we'll run Sidekiq alongside the API.

Update the API service to run both:

Option A: Modify Procfile to run both (simpler for demo):
```bash
# Edit apps/api/Procfile to:
web: bundle exec puma -C config/puma.rb & bundle exec sidekiq -C config/sidekiq.yml
```

Or Option B: Create separate service (recommended for production):
```bash
# Create new service in Railway dashboard
# Use same repository and Dockerfile
# Override start command to: bundle exec sidekiq -C config/sidekiq.yml
```

---

## Step 7: Deploy Next.js Web App

```bash
cd ../web
railway up
```

Railway will detect the Dockerfile and deploy.

Get the API service URL from Railway dashboard, then set environment variables:
```bash
# Replace with your actual API URL from Railway dashboard
railway variables set NODE_ENV=production
railway variables set NEXT_PUBLIC_GRAPHQL_URL=https://your-api-url.railway.app/graphql
railway variables set NEXT_PUBLIC_API_URL=https://your-api-url.railway.app
```

---

## Step 8: Get Your URLs

```bash
railway domain
```

Or check the Railway dashboard for your service URLs.

---

## Step 9: Run Database Migrations

```bash
cd apps/api
railway run rails db:migrate
```

---

## Optional: Add Custom Domains

In Railway dashboard:
1. Go to your service
2. Click "Settings" → "Domains"
3. Add custom domain
4. Update DNS records as shown

---

## Monitoring & Logs

View logs:
```bash
railway logs
```

Or check the Railway dashboard for real-time logs and metrics.

---

## Environment Variables Checklist

### Rails API (Required)
- ✅ `RAILS_ENV=production` (Railway auto-sets)
- ✅ `DATABASE_URL` (Railway auto-sets)
- ✅ `REDIS_URL` (Railway auto-sets)
- ❌ `SECRET_KEY_BASE` - **YOU MUST SET THIS**
- ❌ `OPENAI_API_KEY` - **YOU MUST SET THIS**
- ❌ `AWS_ACCESS_KEY_ID` - **YOU MUST SET THIS**
- ❌ `AWS_SECRET_ACCESS_KEY` - **YOU MUST SET THIS**
- ❌ `AWS_S3_BUCKET` - **YOU MUST SET THIS**
- ❌ `AWS_REGION` - **YOU MUST SET THIS**

### Next.js Web (Required)
- ✅ `NODE_ENV=production`
- ❌ `NEXT_PUBLIC_GRAPHQL_URL` - **YOU MUST SET THIS** (get from API service URL)
- ❌ `NEXT_PUBLIC_API_URL` - **YOU MUST SET THIS** (get from API service URL)

---

## Troubleshooting

### Build fails for Rails API
- Check that all gems are in Gemfile
- Verify Ruby version matches (3.3.5)
- Check Dockerfile syntax

### Build fails for Next.js
- Verify Node version (18.19.0)
- Check package.json scripts
- Ensure all dependencies are listed

### Database connection errors
- Verify DATABASE_URL is set (should be automatic)
- Check migrations ran successfully: `railway run rails db:migrate`

### Redis connection errors
- Verify REDIS_URL is set (should be automatic)
- Check Sidekiq is running

### CORS errors
- Verify NEXT_PUBLIC_GRAPHQL_URL points to correct API URL
- Check Rails CORS configuration in `config/initializers/cors.rb`

---

## Cost Estimate

- PostgreSQL: ~$5/month
- Redis: ~$5/month
- Rails API: ~$5-8/month
- Sidekiq: ~$5/month (if separate)
- Next.js Web: ~$5/month
- **Total: ~$25-30/month**
- **With $5 free credit: ~$20-25/month**

---

## Quick Commands Reference

```bash
# Deploy updates
railway up

# View logs
railway logs

# Run commands
railway run <command>

# Check status
railway status

# Open dashboard
railway open

# Link to existing project
railway link
```

