module Mutations
  class CreateIntakeMessage < BaseMutation
    description "Create a new user intake message for an onboarding session"

    argument :input, Types::Inputs::CreateIntakeMessageInput, required: true

    field :message, Types::IntakeMessageType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      require_authentication!

      session = current_user.onboarding_sessions.find_by(id: input.session_id)

      unless session
        return { message: nil, errors: ["Session not found"] }
      end

      message = session.intake_messages.new(
        role: 'user',
        content: input.content
      )

      if message.save
        # Log audit trail
        AuditLog.log_access(
          actor: current_user,
          action: 'write',
          entity: message
        )

        { message: message, errors: [] }
      else
        { message: nil, errors: message.errors.full_messages }
      end
    end
  end
end

