# Encryption configuration for PHI/PII data
# Uses Rails 7+ built-in encryption (ActiveRecord::Encryption)

# Generate keys with: rails db:encryption:init
# This will output keys to set in your environment

Rails.application.config.active_record.encryption.tap do |config|
  # Primary key for encryption
  config.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY") {
    # Development-only fallback - NEVER use in production
    Rails.env.development? ? "dev_primary_key_for_local_only_32chars!" : raise("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY not set")
  }

  # Deterministic key - allows searching encrypted data
  config.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY") {
    Rails.env.development? ? "dev_deterministic_key_32_chars_min!" : raise("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY not set")
  }

  # Key derivation salt
  config.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT") {
    Rails.env.development? ? "dev_key_derivation_salt_32chars_!" : raise("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT not set")
  }

  # Support unencrypted data during migration period
  config.support_unencrypted_data = Rails.env.development?

  # Encrypt deterministically for searchable fields (member_id)
  # Non-deterministic for maximum security on non-searchable fields
  config.extend_queries = true
end

