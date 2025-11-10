module Mutations
  class AiIntakeMessage < BaseMutation
    description "Send a message in the AI intake conversation"

    argument :input, Types::Inputs::AiIntakeMessageInput, required: true

    field :message, Types::IntakeMessageType, null: false
    field :assistant_response, Types::IntakeMessageType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { message: nil, assistant_response: nil, errors: ["Authentication required"] }
      end

      session = parent.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { message: nil, assistant_response: nil, errors: ["Session not found"] }
      end

      # Create user message
      user_message = IntakeMessage.new(
        onboarding_session: session,
        role: 'user',
        content: input.message
      )

      unless user_message.save
        return { message: nil, assistant_response: nil, errors: user_message.errors.full_messages }
      end

      # TODO: Call AI service to get assistant response
      # For now, create a placeholder assistant response
      assistant_message = IntakeMessage.create!(
        onboarding_session: session,
        role: 'assistant',
        content: "Thank you for sharing that. Can you tell me more?"
      )

      # Log audit trail
      AuditLog.log_access(
        actor: parent,
        action: 'write',
        entity: user_message
      )

      {
        message: user_message,
        assistant_response: assistant_message,
        errors: []
      }
    end
  end
end

