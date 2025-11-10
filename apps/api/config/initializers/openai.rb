# OpenAI Configuration
# API key should be set in credentials or environment variable
# 
# To set in credentials:
# rails credentials:edit
# Add: openai_api_key: your_key_here
#
# Or set environment variable:
# OPENAI_API_KEY=your_key_here

Rails.application.config.openai_model = ENV.fetch('OPENAI_MODEL', 'gpt-4o')
Rails.application.config.openai_max_tokens = ENV.fetch('OPENAI_MAX_TOKENS', '1000').to_i
Rails.application.config.openai_temperature = ENV.fetch('OPENAI_TEMPERATURE', '0.7').to_f

