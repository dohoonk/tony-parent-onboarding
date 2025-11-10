#!/bin/bash

# Script to generate all encryption keys for environment variables
# Usage: ./scripts/generate-env-keys.sh

set -e

echo "🔑 Generating Environment Variable Keys"
echo "========================================"
echo ""

# Check if openssl is available
if ! command -v openssl &> /dev/null; then
    echo "❌ Error: openssl is not installed"
    echo "   Install it with: brew install openssl (macOS) or apt-get install openssl (Linux)"
    exit 1
fi

echo "📝 Generating encryption keys..."
echo ""

# Generate keys
PRIMARY_KEY=$(openssl rand -hex 32)
DETERMINISTIC_KEY=$(openssl rand -hex 32)
DERIVATION_SALT=$(openssl rand -hex 32)
JWT_SECRET=$(openssl rand -hex 32)

echo "✅ Keys generated successfully!"
echo ""
echo "Copy these values to your apps/api/.env file:"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=$PRIMARY_KEY"
echo ""
echo "ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=$DETERMINISTIC_KEY"
echo ""
echo "ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=$DERIVATION_SALT"
echo ""
echo "JWT_SECRET=$JWT_SECRET"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT:"
echo "   - Keep these keys secret and secure"
echo "   - Never commit them to git"
echo "   - Use different keys for development and production"
echo "   - Store production keys in a secrets manager"
echo ""
echo "📖 See ENV_SETUP_GUIDE.md for instructions on getting other environment variables"
echo ""

