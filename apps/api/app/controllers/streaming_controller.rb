class StreamingController < ApplicationController
  include Authentication

  # Stream AI intake response using Server-Sent Events
  def stream_intake
    require_authentication!

    session = current_user.onboarding_sessions.find_by(id: params[:session_id])
    return head :not_found unless session

    user_message = session.intake_messages.find_by(id: params[:message_id])
    return head :not_found unless user_message

    # Set up SSE headers
    response.headers['Content-Type'] = 'text/event-stream'
    response.headers['Cache-Control'] = 'no-cache'
    response.headers['X-Accel-Buffering'] = 'no' # Disable nginx buffering

    # Get conversation history including the most recent user message
    messages = session.intake_messages.order(:created_at)
    conversation_messages = IntakePromptService.build_messages(messages)

    # Stream AI response
    openai_service = OpenaiService.new
    assistant_message = nil
    full_content = ''

    begin
      openai_service.stream_chat_completion(
        messages: conversation_messages,
        system_prompt: IntakePromptService.system_prompt
      ) do |chunk|
        full_content += chunk
        # Send chunk to client
        response.stream.write("data: #{JSON.generate({ content: chunk, type: 'chunk' })}\n\n")
      end

      # Create assistant message with full content
      assistant_message = IntakeMessage.create!(
        onboarding_session: session,
        role: 'assistant',
        content: full_content
      )

      # Send completion event
      response.stream.write("data: #{JSON.generate({ type: 'complete', message_id: assistant_message.id })}\n\n")

      # Log audit trail
      AuditLog.log_access(
        actor: current_user,
        action: 'write',
        entity: assistant_message
      )
    rescue StandardError => e
      Rails.logger.error("Streaming error: #{e.message}")
      response.stream.write("data: #{JSON.generate({ type: 'error', message: 'Failed to generate response' })}\n\n")
    ensure
      response.stream.close
    end
  end
end

