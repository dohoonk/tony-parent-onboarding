module Mutations
  class SupportChatMessage < BaseMutation
    description "Send a message in the support chat"

    argument :session_id, ID, required: true
    argument :message, String, required: true

    field :response, String, null: false
    field :escalated, Boolean, null: false
    field :escalation_id, String, null: true
    field :errors, [String], null: false

    def resolve(session_id:, message:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: session_id)
      
      unless session
        return { response: nil, escalated: false, escalation_id: nil, errors: ["Session not found"] }
      end

      # Process message
      result = SupportChatService.process_message(
        message: message,
        session_id: session.id
      )

      # Log chat interaction
      AuditLog.log_access(
        actor: current_user,
        action: 'write',
        entity: session,
        after: {
          support_chat_message: message,
          escalated: result[:escalated],
          escalation_id: result[:escalation_id]
        }
      )

      {
        response: result[:answer],
        escalated: result[:escalated] || false,
        escalation_id: result[:escalation_id],
        errors: []
      }
    rescue StandardError => e
      Rails.logger.error("Support chat mutation failed: #{e.message}")
      { response: nil, escalated: false, escalation_id: nil, errors: ["Failed to process message: #{e.message}"] }
    end
  end
end

