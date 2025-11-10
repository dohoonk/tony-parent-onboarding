module Errors
  class ValidationError < BaseError
    def initialize(message: "Validation failed", errors: [], **options)
      extensions = options[:extensions] || {}
      extensions[:validation_errors] = errors if errors.any?

      super(
        message: message,
        error_code: 'VALIDATION_FAILED',
        status_code: 422,
        extensions: extensions,
        **options.except(:extensions)
      )
    end

    def self.from_active_record(record)
      new(
        message: "Validation failed: #{record.errors.full_messages.join(', ')}",
        errors: record.errors.messages
      )
    end
  end
end

