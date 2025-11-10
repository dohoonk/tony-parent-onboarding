module Errors
  class AuthorizationError < BaseError
    def initialize(message: "Insufficient permissions", **options)
      super(
        message: message,
        error_code: 'AUTHORIZATION_FAILED',
        status_code: 403,
        **options
      )
    end
  end
end

