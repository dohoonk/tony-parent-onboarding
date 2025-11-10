# Environment Variables Setup Guide

This guide will help you obtain each required environment variable step by step.

---

## Rails API Environment Variables

### 1. `OPENAI_API_KEY`

**What it's for:** Powers AI features (intake conversations, OCR extraction, screener interpretation)

**Where to get it:**
1. Go to https://platform.openai.com/
2. Sign up or log in to your OpenAI account
3. Navigate to: **API Keys** (in the left sidebar or https://platform.openai.com/api-keys)
4. Click **"Create new secret key"**
5. Give it a name (e.g., "Parent Onboarding Dev")
6. Click **"Create secret key"**
7. **IMPORTANT:** Copy the key immediately - you won't be able to see it again!
   - Format: `sk-proj-...` or `sk-...`

**How to set it:**
```bash
# In apps/api/.env
OPENAI_API_KEY=sk-proj-your-actual-key-here
```

**Cost:** Pay-as-you-go. Check pricing at https://openai.com/pricing
- GPT-4o: ~$2.50-$5.00 per 1M input tokens
- GPT-4o-mini: ~$0.15-$0.60 per 1M input tokens

---

### 2. `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`

**What it's for:** Uploading insurance card images to AWS S3

**Where to get it:**
1. Go to https://aws.amazon.com/
2. Sign up or log in to your AWS account
3. Navigate to **IAM (Identity and Access Management)**
   - Search for "IAM" in the AWS console
   - Or go to: https://console.aws.amazon.com/iam/
4. Click **"Users"** in the left sidebar
5. Click **"Create user"**
   - Username: `parent-onboarding-s3-uploader-tony` (or your choice)
   - Access type: **Programmatic access** (check this box)
   - Click **"Next: Permissions"**
6. **On the "Access key best practices & alternatives" page:**
   - **Select: "Local code"** - This option says: "You plan to use this access key to enable application code in a local development environment to access your AWS account."
   - This is the correct choice for local Rails development
   - Click **"Next"** to continue
7. Attach permissions:
   - Click **"Attach existing policies directly"**
   - Search for and select: **"AmazonS3FullAccess"** (or create a more restrictive policy)
   - Click **"Next: Tags"** (optional)
   - Click **"Next: Review"**
   - Click **"Create user"**
8. **IMPORTANT:** Copy both keys immediately:
   - **Access key ID**: e.g., `AKIAIOSFODNN7EXAMPLE`
   - **Secret access key**: e.g., `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`
   - You can download a CSV file with both keys
   - ⚠️ **You won't be able to see the secret key again after this step!**

**How to set it:**
```bash
# In apps/api/.env
AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
```

**Security Note:** For production, create a more restrictive IAM policy that only allows:
- `s3:PutObject` on your specific bucket
- `s3:GetObject` on your specific bucket

---

### 3. `AWS_S3_BUCKET`

**What it's for:** The S3 bucket name where insurance card images will be stored

**Where to get it:**
1. Go to https://console.aws.amazon.com/s3/
2. Click **"Create bucket"**
3. Configure bucket:
   - **Bucket name**: `parent-onboarding-insurance-cards` (must be globally unique)
   - **Region**: Choose closest to you (e.g., `us-east-1`)
   - **Block Public Access**: Keep enabled for security
   - **Versioning**: Optional (enable if you want to track changes)
   - Click **"Create bucket"**
4. Copy the bucket name

**How to set it:**
```bash
# In apps/api/.env
AWS_S3_BUCKET=parent-onboarding-insurance-cards
```

**Note:** The bucket name must be globally unique across all AWS accounts.

---

### 4. `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`

**What it's for:** Encrypts sensitive PHI (Protected Health Information) in the database

**How to generate it:**
```bash
cd apps/api
rails secret
# This will output a random 32+ character string
```

**Or generate manually:**
```bash
# Using OpenSSL (recommended)
openssl rand -hex 32

# Or using Ruby
ruby -e "require 'securerandom'; puts SecureRandom.hex(32)"
```

**How to set it:**
```bash
# In apps/api/.env
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=your-32-character-hex-string-here
```

**Security:** This must be at least 32 characters. Keep it secret!

---

### 5. `ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY`

**What it's for:** Allows searching encrypted data (deterministic encryption)

**How to generate it:**
```bash
# Same as above - generate a different 32+ character string
openssl rand -hex 32
```

**How to set it:**
```bash
# In apps/api/.env
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=your-different-32-character-hex-string-here
```

**Important:** This must be different from the PRIMARY_KEY!

---

### 6. `ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT`

**What it's for:** Salt used in key derivation for encryption

**How to generate it:**
```bash
# Generate another 32+ character string
openssl rand -hex 32
```

**How to set it:**
```bash
# In apps/api/.env
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=your-another-32-character-hex-string-here
```

**Important:** This must be different from both PRIMARY_KEY and DETERMINISTIC_KEY!

---

### 7. `JWT_SECRET`

**What it's for:** Signing and verifying JWT authentication tokens

**How to generate it:**
```bash
cd apps/api
rails secret
# Or use the same method as encryption keys
openssl rand -hex 32
```

**How to set it:**
```bash
# In apps/api/.env
JWT_SECRET=your-32-character-hex-string-here
```

**Security:** Keep this secret! If compromised, attackers could forge authentication tokens.

---

### 8. `DATABASE_URL`

**What it's for:** PostgreSQL database connection string

**Format:**
```
postgresql://username:password@host:port/database_name
```

**For local development:**
```bash
# In apps/api/.env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/parent_onboarding_development
```

**How to get it:**
1. **If using local PostgreSQL:**
   - Default username: `postgres` (or your PostgreSQL username)
   - Default password: `postgres` (or your PostgreSQL password)
   - Default host: `localhost`
   - Default port: `5432`
   - Database name: `parent_onboarding_development` (created when you run `rails db:create`)

2. **If using Docker:**
   - Check your `docker-compose.yml` for the database configuration
   - Usually: `postgresql://postgres:postgres@db:5432/parent_onboarding_development`

3. **If using a cloud database (e.g., Heroku, AWS RDS):**
   - The provider will give you a connection string
   - Format: `postgresql://user:pass@host:5432/dbname`

**How to set it:**
```bash
# In apps/api/.env
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/parent_onboarding_development
```

**Note:** You can also set individual components:
```bash
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=postgres
DB_NAME=parent_onboarding_development
```

---

## Next.js Web Environment Variables

### 9. `NEXT_PUBLIC_API_URL`

**What it's for:** Base URL for the Rails API (used for non-GraphQL endpoints)

**For local development:**
```bash
# In apps/web/.env.local
NEXT_PUBLIC_API_URL=http://localhost:3000
```

**For production:**
```bash
NEXT_PUBLIC_API_URL=https://api.yourdomain.com
```

**How to set it:**
- Just use the URL where your Rails API is running
- Default Rails development server: `http://localhost:3000`

---

### 10. `NEXT_PUBLIC_GRAPHQL_URL`

**What it's for:** GraphQL endpoint URL

**For local development:**
```bash
# In apps/web/.env.local
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
```

**For production:**
```bash
NEXT_PUBLIC_GRAPHQL_URL=https://api.yourdomain.com/graphql
```

**How to set it:**
- This is typically `{API_URL}/graphql`
- Default: `http://localhost:3000/graphql`

---

## Quick Setup Script

You can use this script to generate all the encryption keys at once:

```bash
#!/bin/bash
# Generate all encryption keys

echo "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$(openssl rand -hex 32)"
echo "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$(openssl rand -hex 32)"
echo "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$(openssl rand -hex 32)"
echo "JWT_SECRET=$(openssl rand -hex 32)"
```

Save this as `generate-keys.sh`, make it executable (`chmod +x generate-keys.sh`), and run it:
```bash
./generate-keys.sh
```

---

## Complete .env File Template

### `apps/api/.env`

```bash
# Database
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/parent_onboarding_development

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# OpenAI (REQUIRED for AI features)
OPENAI_API_KEY=sk-proj-YOUR_KEY_HERE

# AWS S3 (REQUIRED for file uploads)
AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY
AWS_S3_BUCKET=parent-onboarding-insurance-cards

# Rails Encryption (REQUIRED for PHI encryption)
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=GENERATE_WITH_openssl_rand_hex_32
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=GENERATE_WITH_openssl_rand_hex_32
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=GENERATE_WITH_openssl_rand_hex_32

# JWT Authentication
JWT_SECRET=GENERATE_WITH_openssl_rand_hex_32

# Optional: OpenAI Model Configuration
OPENAI_MODEL=gpt-4o
OPENAI_MAX_TOKENS=1000
OPENAI_TEMPERATURE=0.7
```

### `apps/web/.env.local`

```bash
# API URLs
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
```

---

## Step-by-Step Setup Process

### Step 1: Generate Encryption Keys

```bash
cd "/Users/dohoonkim/GauntletAI/Parent Onboarding/apps/api"

# Generate all keys at once
echo "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$(openssl rand -hex 32)"
echo "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$(openssl rand -hex 32)"
echo "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$(openssl rand -hex 32)"
echo "JWT_SECRET=$(openssl rand -hex 32)"
```

Copy each output and save them somewhere safe.

### Step 2: Get OpenAI API Key

1. Visit: https://platform.openai.com/api-keys
2. Click "Create new secret key"
3. Copy the key (starts with `sk-`)

### Step 3: Set Up AWS S3

1. Visit: https://console.aws.amazon.com/s3/
2. Create a bucket (note the name)
3. Visit: https://console.aws.amazon.com/iam/
4. Create a user with S3 access
5. Copy Access Key ID and Secret Access Key

### Step 4: Create .env Files

```bash
# Create API .env file
cd apps/api
cat > .env << 'EOF'
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/parent_onboarding_development
REDIS_URL=redis://localhost:6379/0
OPENAI_API_KEY=YOUR_OPENAI_KEY_HERE
AWS_ACCESS_KEY_ID=YOUR_AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=YOUR_AWS_SECRET_KEY
AWS_S3_BUCKET=your-bucket-name
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=YOUR_PRIMARY_KEY
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=YOUR_DETERMINISTIC_KEY
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=YOUR_SALT
JWT_SECRET=YOUR_JWT_SECRET
EOF

# Create Web .env.local file
cd ../web
cat > .env.local << 'EOF'
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_GRAPHQL_URL=http://localhost:3000/graphql
EOF
```

### Step 5: Replace Placeholders

Edit both `.env` files and replace all `YOUR_*_HERE` placeholders with your actual values.

---

## Verification

After setting up all variables, verify they're working:

```bash
# Test Rails can read environment variables
cd apps/api
rails runner "puts ENV['OPENAI_API_KEY'] ? 'OpenAI key set' : 'OpenAI key missing'"
rails runner "puts ENV['AWS_ACCESS_KEY_ID'] ? 'AWS key set' : 'AWS key missing'"

# Test Next.js can read environment variables
cd ../web
node -e "console.log(process.env.NEXT_PUBLIC_API_URL || 'API URL missing')"
```

---

## Security Best Practices

1. **Never commit .env files to git** (already in .gitignore)
2. **Use different keys for development and production**
3. **Rotate keys regularly** (especially if compromised)
4. **Use AWS IAM roles in production** (instead of access keys when possible)
5. **Store production keys in a secrets manager** (AWS Secrets Manager, HashiCorp Vault, etc.)
6. **Use environment-specific .env files** (.env.development, .env.production)

---

## Troubleshooting

### "OPENAI_API_KEY not set"
- Check that `.env` file exists in `apps/api/`
- Verify the key starts with `sk-`
- Restart Rails server after adding the key

### "AWS credentials not found"
- Verify AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY are set
- Check that AWS credentials are valid (test with AWS CLI)
- Ensure S3 bucket exists and is accessible

### "Encryption keys not set"
- All three encryption keys must be set
- Each must be at least 32 characters
- They must all be different from each other

### "Database connection failed"
- Verify PostgreSQL is running: `pg_isready`
- Check DATABASE_URL format is correct
- Ensure database exists: `rails db:create`

---

## Need Help?

- **OpenAI Issues:** https://help.openai.com/
- **AWS Issues:** https://aws.amazon.com/support/
- **Rails Issues:** Check `apps/api/log/development.log`
- **Next.js Issues:** Check browser console and terminal output

---

**Last Updated:** 2025-11-10

