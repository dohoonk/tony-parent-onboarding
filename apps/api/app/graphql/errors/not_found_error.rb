module Errors
  class NotFoundError < BaseError
    def initialize(message: "Resource not found", resource: nil, **options)
      extensions = options[:extensions] || {}
      extensions[:resource] = resource if resource

      super(
        message: message,
        error_code: 'NOT_FOUND',
        status_code: 404,
        extensions: extensions,
        **options.except(:extensions)
      )
    end
  end
end

