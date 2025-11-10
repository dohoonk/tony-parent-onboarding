class ProcessAiIntakeJob < ApplicationJob
  queue_as :default

  def perform(session_id, user_message_id)
    session = OnboardingSession.find(session_id)
    user_message = IntakeMessage.find(user_message_id)

    # Get conversation history
    messages = session.intake_messages.order(:created_at)
    conversation_messages = IntakePromptService.build_messages(messages)

    # Get AI response
    openai_service = OpenaiService.new
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
      actor: session.parent,
      action: 'write',
      entity: assistant_message
    )

    # Return message for GraphQL response
    assistant_message
  rescue StandardError => e
    Rails.logger.error("AI intake processing failed: #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise
  end
end

