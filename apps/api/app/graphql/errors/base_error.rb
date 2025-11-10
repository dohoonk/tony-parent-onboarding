module Errors
  class BaseError < GraphQL::ExecutionError
    attr_reader :error_code, :status_code

    def initialize(message:, error_code: nil, status_code: 400, extensions: {})
      @error_code = error_code || self.class.name.demodulize.underscore
      @status_code = status_code
      
      super(
        message,
        extensions: extensions.merge(
          code: @error_code,
          status: @status_code
        )
      )
    end

    def to_h
      {
        message: message,
        code: error_code,
        status: status_code,
        extensions: extensions
      }
    end
  end
end

