module Mutations
  class CreateAvailabilityWindow < BaseMutation
    description "Create an availability window for the current parent"

    argument :input, Types::Inputs::CreateAvailabilityWindowInput, required: true

    field :availability_window, Types::AvailabilityWindowType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      require_authentication!

      availability_window = current_user.availability_windows.new(
        start_date: input.start_date || Date.current,
        end_date: input.end_date,
        timezone: input.timezone || default_timezone,
        availability_json: input.availability_json
      )

      if availability_window.save
        AuditLog.log_access(
          actor: current_user,
          action: 'write',
          entity: availability_window,
          after: availability_window.attributes
        )

        { availability_window: availability_window, errors: [] }
      else
        { availability_window: nil, errors: availability_window.errors.full_messages }
      end
    end

    private

    def default_timezone
      current_user.try(:preferred_timezone) || 'America/Los_Angeles'
    end
  end
end




