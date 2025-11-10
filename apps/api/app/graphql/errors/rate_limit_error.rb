module Errors
  class RateLimitError < BaseError
    def initialize(message: "Rate limit exceeded", retry_after: nil, **options)
      extensions = options[:extensions] || {}
      extensions[:retry_after] = retry_after if retry_after

      super(
        message: message,
        error_code: 'RATE_LIMIT_EXCEEDED',
        status_code: 429,
        extensions: extensions,
        **options.except(:extensions)
      )
    end
  end
end

