#!/bin/bash

# Railway Deployment Script
# Run this script to deploy your application to Railway

set -e  # Exit on error

echo "🚀 Railway Deployment Script"
echo "================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if logged in
echo "Checking Railway login status..."
if ! railway whoami > /dev/null 2>&1; then
    echo -e "${RED}❌ Not logged in to Railway${NC}"
    echo "Please run: railway login"
    exit 1
fi

echo -e "${GREEN}✅ Logged in to Railway${NC}"
echo ""

# Get project root
PROJECT_ROOT="/Users/dohoonkim/GauntletAI/Parent Onboarding"
cd "$PROJECT_ROOT"

echo "📦 Project: parent-onboarding"
echo ""

# Check if environment variables are set
echo "⚠️  IMPORTANT: You need these environment variables ready:"
echo "  - OPENAI_API_KEY"
echo "  - AWS_ACCESS_KEY_ID"
echo "  - AWS_SECRET_ACCESS_KEY"
echo "  - AWS_S3_BUCKET"
echo "  - AWS_REGION"
echo ""
read -p "Do you have all these ready? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please get your API keys first. See ENV_SETUP_GUIDE.md${NC}"
    exit 1
fi

echo ""
echo "================================"
echo "Step 1: Deploy Rails API"
echo "================================"
echo ""

cd "$PROJECT_ROOT/apps/api"

echo "Creating and deploying API service..."
railway up --detach

echo ""
echo -e "${GREEN}✅ API deployment started!${NC}"
echo ""

# Prompt for environment variables
echo "Now let's set the environment variables for the API..."
echo ""

read -p "Enter your OPENAI_API_KEY: " OPENAI_KEY
read -p "Enter your AWS_ACCESS_KEY_ID: " AWS_KEY_ID
read -p "Enter your AWS_SECRET_ACCESS_KEY: " AWS_SECRET
read -p "Enter your AWS_S3_BUCKET: " S3_BUCKET
read -p "Enter your AWS_REGION (default: us-east-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-us-east-1}

echo ""
echo "Setting environment variables..."

railway variables set OPENAI_API_KEY="$OPENAI_KEY"
railway variables set AWS_ACCESS_KEY_ID="$AWS_KEY_ID"
railway variables set AWS_SECRET_ACCESS_KEY="$AWS_SECRET"
railway variables set AWS_S3_BUCKET="$S3_BUCKET"
railway variables set AWS_REGION="$AWS_REGION"
railway variables set SECRET_KEY_BASE="$(openssl rand -hex 64)"
railway variables set RAILS_ENV=production
railway variables set RAILS_SERVE_STATIC_FILES=true
railway variables set RAILS_LOG_TO_STDOUT=true

echo -e "${GREEN}✅ Environment variables set!${NC}"
echo ""

# Wait a bit for deployment
echo "Waiting for API service to start..."
sleep 10

# Run migrations
echo "Running database migrations..."
railway run rails db:migrate || echo -e "${YELLOW}⚠️  Migrations may run automatically on first deploy${NC}"

echo ""
echo "Getting API URL..."
API_URL=$(railway domain 2>/dev/null || echo "")

if [ -z "$API_URL" ]; then
    echo -e "${YELLOW}⚠️  No domain found yet. Generating one...${NC}"
    railway domain
    sleep 5
    API_URL=$(railway domain 2>/dev/null || echo "unknown")
fi

echo -e "${GREEN}✅ API deployed!${NC}"
echo "API URL: https://$API_URL"
echo ""

echo "================================"
echo "Step 2: Deploy Next.js Web App"
echo "================================"
echo ""

cd "$PROJECT_ROOT/apps/web"

echo "Creating and deploying Web service..."
railway up --detach

echo ""
echo "Setting web environment variables..."

if [ "$API_URL" != "unknown" ]; then
    railway variables set NEXT_PUBLIC_GRAPHQL_URL="https://$API_URL/graphql"
    railway variables set NEXT_PUBLIC_API_URL="https://$API_URL"
    railway variables set NODE_ENV=production
else
    echo -e "${RED}❌ Could not get API URL automatically${NC}"
    echo "Please set these manually in Railway dashboard:"
    echo "  NEXT_PUBLIC_GRAPHQL_URL=https://YOUR-API-URL/graphql"
    echo "  NEXT_PUBLIC_API_URL=https://YOUR-API-URL"
fi

echo ""
echo "Getting Web URL..."
sleep 10
WEB_URL=$(railway domain 2>/dev/null || echo "")

if [ -z "$WEB_URL" ]; then
    echo -e "${YELLOW}⚠️  No domain found yet. Generating one...${NC}"
    railway domain
    WEB_URL=$(railway domain 2>/dev/null || echo "unknown")
fi

echo ""
echo "================================"
echo "🎉 Deployment Complete!"
echo "================================"
echo ""
echo "Your application is deployed:"
echo ""
echo "📊 API: https://$API_URL"
echo "🌐 Web: https://$WEB_URL"
echo ""
echo "Next steps:"
echo "1. Open https://$WEB_URL in your browser"
echo "2. Test the onboarding flow"
echo "3. Check logs: railway logs"
echo "4. View dashboard: railway open"
echo ""
echo "If anything goes wrong, check:"
echo "  - Railway dashboard: railway open"
echo "  - API logs: cd apps/api && railway logs"
echo "  - Web logs: cd apps/web && railway logs"
echo ""

