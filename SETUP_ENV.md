# Environment Setup Guide

## Quick Start

1. **Copy the example file:**
   ```bash
   cp .env.example .env
   ```

2. **Generate Rails secret keys:**
   ```bash
   cd apps/api
   rails secret  # Copy this value to SECRET_KEY_BASE and JWT_SECRET_KEY in .env
   ```

3. **Fill in your credentials:**
   - OpenAI API key (required for AI features)
   - AWS credentials (required for file uploads)
   - Database password (if using password authentication)
   - Postmark/Twilio keys (for notifications)

## Required Credentials

### Essential (for basic functionality)
- ✅ `OPENAI_API_KEY` - Get from https://platform.openai.com/api-keys
- ✅ `SECRET_KEY_BASE` - Generate with `rails secret`
- ✅ `JWT_SECRET_KEY` - Generate with `rails secret` (can use same as SECRET_KEY_BASE)

### For File Uploads
- ✅ `AWS_ACCESS_KEY_ID` - From AWS IAM
- ✅ `AWS_SECRET_ACCESS_KEY` - From AWS IAM
- ✅ `AWS_S3_BUCKET_NAME` - Your S3 bucket name

### For Notifications (optional for testing)
- `POSTMARK_API_KEY` - For email notifications
- `TWILIO_ACCOUNT_SID` - For SMS notifications
- `TWILIO_AUTH_TOKEN` - For SMS notifications

### Database (usually defaults work)
- `DB_PASSWORD` - Only if your PostgreSQL requires a password
- `PARENT_ONBOARDING_DATABASE_PASSWORD` - For production

## Generating Secret Keys

```bash
cd apps/api

# Generate SECRET_KEY_BASE
rails secret
# Copy output to .env file

# For JWT_SECRET_KEY, you can use the same value or generate another
rails secret
```

## Testing Your Setup

After setting up `.env`, test that everything works:

```bash
# Test database connection
cd apps/api
rails db:version

# Test Redis connection
redis-cli ping  # Should return "PONG"

# Test OpenAI (in Rails console)
rails console
OpenaiService.new  # Should not error
```

## Environment-Specific Files

You can also create environment-specific files:
- `.env.development` - Development overrides
- `.env.test` - Test environment
- `.env.production` - Production (never commit!)

## Security Notes

⚠️ **Never commit `.env` to git** - It's already in `.gitignore`

✅ **Do commit `.env.example`** - It's a template without secrets

✅ **Use Rails credentials for production secrets:**
```bash
rails credentials:edit
```

## Troubleshooting

### Rails can't find environment variables
- Make sure `.env` is in the project root
- Install `dotenv-rails` gem if needed: `gem 'dotenv-rails'`

### Next.js can't find environment variables
- Variables must be prefixed with `NEXT_PUBLIC_` to be accessible in browser
- Restart Next.js dev server after changing `.env`

### Database connection errors
- Check PostgreSQL is running: `pg_isready`
- Verify database exists: `rails db:create`
- Check credentials in `.env`

