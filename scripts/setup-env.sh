#!/bin/bash

# Setup script to create .env file from template
# Usage: ./scripts/setup-env.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🚀 Setting up environment variables for Parent Onboarding AI"
echo ""

# Check if .env already exists
if [ -f "$PROJECT_ROOT/.env" ]; then
  echo "⚠️  .env file already exists!"
  read -p "Do you want to overwrite it? (y/N): " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Aborted. Keeping existing .env file."
    exit 1
  fi
fi

# Copy template
cp "$PROJECT_ROOT/.env.example" "$PROJECT_ROOT/.env"
echo "✅ Created .env file from template"

# Generate Rails secret keys
echo ""
echo "🔑 Generating Rails secret keys..."
cd "$PROJECT_ROOT/apps/api"

if command -v rails &> /dev/null; then
  SECRET_KEY=$(rails secret 2>/dev/null || echo "")
  if [ -n "$SECRET_KEY" ]; then
    # Update SECRET_KEY_BASE in .env
    if [[ "$OSTYPE" == "darwin"* ]]; then
      # macOS
      sed -i '' "s/SECRET_KEY_BASE=generate_with_rails_secret/SECRET_KEY_BASE=$SECRET_KEY/" "$PROJECT_ROOT/.env"
      sed -i '' "s/JWT_SECRET_KEY=generate_with_rails_secret/JWT_SECRET_KEY=$SECRET_KEY/" "$PROJECT_ROOT/.env"
    else
      # Linux
      sed -i "s/SECRET_KEY_BASE=generate_with_rails_secret/SECRET_KEY_BASE=$SECRET_KEY/" "$PROJECT_ROOT/.env"
      sed -i "s/JWT_SECRET_KEY=generate_with_rails_secret/JWT_SECRET_KEY=$SECRET_KEY/" "$PROJECT_ROOT/.env"
    fi
    echo "✅ Generated and set SECRET_KEY_BASE and JWT_SECRET_KEY"
  else
    echo "⚠️  Could not generate Rails secret. Please run 'rails secret' manually and update .env"
  fi
else
  echo "⚠️  Rails not found. Please generate secrets manually with 'rails secret'"
fi

echo ""
echo "📝 Next steps:"
echo "1. Edit .env file and fill in your credentials:"
echo "   - OPENAI_API_KEY (required for AI features)"
echo "   - AWS credentials (required for file uploads)"
echo "   - Database password (if needed)"
echo "   - Postmark/Twilio keys (for notifications)"
echo ""
echo "2. Required credentials:"
echo "   ✅ OPENAI_API_KEY - Get from https://platform.openai.com/api-keys"
echo "   ✅ AWS_ACCESS_KEY_ID & AWS_SECRET_ACCESS_KEY - From AWS IAM"
echo "   ✅ AWS_S3_BUCKET_NAME - Your S3 bucket name"
echo ""
echo "3. Optional (for notifications):"
echo "   - POSTMARK_API_KEY - For email"
echo "   - TWILIO_ACCOUNT_SID & TWILIO_AUTH_TOKEN - For SMS"
echo ""
echo "📖 See SETUP_ENV.md for detailed instructions"
echo ""
echo "✨ Setup complete! Edit .env with your credentials."

