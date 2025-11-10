module Mutations
  class StreamAiIntakeMessage < BaseMutation
    description "Send a message in the AI intake conversation and stream the response"

    argument :input, Types::Inputs::AiIntakeMessageInput, required: true

    field :message, Types::IntakeMessageType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { message: nil, errors: ["Session not found"] }
      end

      # Create user message
      user_message = IntakeMessage.new(
        onboarding_session: session,
        role: 'user',
        content: input.message
      )

      unless user_message.save
        return { message: nil, errors: user_message.errors.full_messages }
      end

      # Get conversation history
      messages = session.intake_messages.where.not(id: user_message.id).order(:created_at)
      conversation_messages = IntakePromptService.build_messages(messages)

      # Get AI response with streaming
      openai_service = OpenaiService.new
      
      # For now, we'll use non-streaming and return immediately
      # Streaming will be implemented via ActionCable or SSE in a future iteration
      response = openai_service.chat_completion(
        messages: conversation_messages,
        system_prompt: IntakePromptService.system_prompt
      )

      # Create assistant message
      assistant_message = IntakeMessage.create!(
        onboarding_session: session,
        role: 'assistant',
        content: response[:content]
      )

      # Log audit trail
      AuditLog.log_access(
        actor: current_user,
        action: 'write',
        entity: user_message
      )

      AuditLog.log_access(
        actor: current_user,
        action: 'write',
        entity: assistant_message
      )

      {
        message: user_message,
        assistant_response: assistant_message,
        errors: []
      }
    end
  end
end

