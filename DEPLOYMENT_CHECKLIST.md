# 📋 Railway Deployment Checklist

## ✅ Pre-Deployment (Already Done!)

- [x] Created `apps/api/Procfile` for Rails
- [x] Created `apps/web/Procfile` for Next.js
- [x] Enabled CORS for Railway domains
- [x] Configured production environment for Railway
- [x] Railway CLI installed

## 🔑 Environment Variables You'll Need

### OpenAI API Key
**Get it from:** https://platform.openai.com/api-keys
- Sign up/login
- Create new secret key
- Format: `sk-proj-...` or `sk-...`

### AWS Credentials (for S3)
**Get it from:** https://console.aws.amazon.com/iam/
1. Create IAM user with S3 access
2. Get Access Key ID and Secret Access Key
3. Create S3 bucket for insurance cards

**You need:**
- `AWS_ACCESS_KEY_ID` (e.g., `AKIAIOSFODNN7EXAMPLE`)
- `AWS_SECRET_ACCESS_KEY` (e.g., `wJalrXUtnFEMI/K7MDENG/...`)
- `AWS_S3_BUCKET` (e.g., `parent-onboarding-demo-cards`)
- `AWS_REGION` (e.g., `us-east-1`)

See `ENV_SETUP_GUIDE.md` for detailed instructions!

---

## 🚀 Deployment Steps (Run These in Terminal)

### 1. Login to Railway
```bash
railway login
```

### 2. Initialize Project
```bash
cd "/Users/dohoonkim/GauntletAI/Parent Onboarding"
railway init
```
Choose: **Empty Project**

### 3. Add Databases
```bash
railway add --database postgresql
railway add --database redis
```

### 4. Deploy API
```bash
cd apps/api
railway up
```

Wait for deployment to complete...

### 5. Set API Environment Variables
```bash
# Required
railway variables set OPENAI_API_KEY=sk-your-actual-key
railway variables set AWS_ACCESS_KEY_ID=AKIA...
railway variables set AWS_SECRET_ACCESS_KEY=wJal...
railway variables set AWS_S3_BUCKET=your-bucket-name
railway variables set AWS_REGION=us-east-1
railway variables set SECRET_KEY_BASE=$(openssl rand -hex 64)

# Run database migrations
railway run rails db:migrate
```

### 6. Get API URL
```bash
railway domain
```
**Copy this URL!** You'll need it for the next step.

### 7. Deploy Web App
```bash
cd ../web
railway up
```

Wait for deployment to complete...

### 8. Set Web Environment Variables
```bash
# Replace YOUR-API-URL with the URL from step 6
railway variables set NEXT_PUBLIC_GRAPHQL_URL=https://YOUR-API-URL.railway.app/graphql
railway variables set NEXT_PUBLIC_API_URL=https://YOUR-API-URL.railway.app
```

### 9. Get Web App URL
```bash
railway domain
```

### 10. Test Your App! 🎉
Open the web URL in your browser and test the onboarding flow!

---

## 🔍 Verification Checklist

After deployment, verify:
- [ ] Web app loads without errors
- [ ] Can start onboarding flow
- [ ] AI chat works (requires OpenAI key)
- [ ] Insurance card upload works (requires AWS S3)
- [ ] No CORS errors in browser console
- [ ] API GraphQL endpoint accessible

---

## 🐛 Troubleshooting

### "Blocked host" error
**Solution:** Already fixed! The production config allows Railway domains.

### CORS errors
**Solution:** Already fixed! CORS is configured for Railway domains.

### "Can't connect to API"
**Solution:** Make sure `NEXT_PUBLIC_GRAPHQL_URL` is set correctly in the web app.

### "OpenAI API error"
**Solution:** Verify `OPENAI_API_KEY` is set in the API service.

### "S3 upload fails"
**Solution:** Verify all AWS credentials are set correctly.

### View logs
```bash
cd apps/api   # or apps/web
railway logs
```

### Restart service
```bash
railway up
```

---

## 💰 Cost Reminder

- **Month 1-12:** ~$20-25/month (with $5 free credit)
- **After Year 1:** ~$25-30/month

Most expensive part will be OpenAI API usage (~$0.005 per conversation).

---

## 🎯 Quick Commands

```bash
# View all services
railway status

# Open Railway dashboard
railway open

# View logs
railway logs

# Run Rails console
railway run rails console

# Run one-off commands
railway run <command>
```

---

## 📞 Need Help?

- Railway Docs: https://docs.railway.app/
- Railway Discord: https://discord.gg/railway
- Check `RAILWAY_DEPLOYMENT.md` for detailed explanations

