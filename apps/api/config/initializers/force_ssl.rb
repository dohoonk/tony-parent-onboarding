# Force SSL/TLS 1.2+ for all connections
# This ensures encrypted transmission of PHI

Rails.application.config.force_ssl = true if Rails.env.production?

# Configure SSL options
if Rails.env.production?
  Rails.application.config.ssl_options = {
    redirect: { exclude: ->(request) { request.path.start_with?('/health') } },
    hsts: {
      expires: 1.year,
      subdomains: true,
      preload: true
    },
    secure_cookies: true
  }
end

# Log SSL/TLS configuration
Rails.logger.info("SSL/TLS Configuration: force_ssl=#{Rails.application.config.force_ssl}") if Rails.env.development?

