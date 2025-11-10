module Errors
  class AuthenticationError < BaseError
    def initialize(message: "Authentication required", **options)
      super(
        message: message,
        error_code: 'AUTHENTICATION_REQUIRED',
        status_code: 401,
        **options
      )
    end
  end
end

