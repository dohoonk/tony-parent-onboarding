class SupportChatService
  ESCALATION_KEYWORDS = ['urgent', 'emergency', 'help me', 'not working', 'broken', 'error'].freeze

  # Process support chat message and determine if escalation is needed
  # @param message [String] User's message
  # @param session_id [Integer] Onboarding session ID
  # @return [Hash] Response with answer and escalation status
  def self.process_message(message:, session_id:)
    # Check if escalation is needed
    needs_escalation = check_escalation_needed(message)

    if needs_escalation
      # Escalate to staff
      escalate_to_staff(message: message, session_id: session_id)
      
      return {
        answer: "I've escalated your question to our support team. Someone will respond shortly. In the meantime, is there anything else I can help with?",
        escalated: true,
        escalation_id: create_escalation_ticket(message, session_id)
      }
    else
      # Try AI FAQ first
      answer = FaqService.answer_question(
        question: message,
        context: { session_id: session_id, source: 'support_chat' }
      )

      return {
        answer: answer,
        escalated: false
      }
    end
  rescue StandardError => e
    Rails.logger.error("Support chat processing failed: #{e.message}")
    # Fallback to escalation on error
    escalate_to_staff(message: message, session_id: session_id)
    {
      answer: "I'm having trouble processing your request. I've escalated it to our support team who will help you shortly.",
      escalated: true
    }
  end

  private

  def self.check_escalation_needed(message)
    message_lower = message.downcase
    ESCALATION_KEYWORDS.any? { |keyword| message_lower.include?(keyword) }
  end

  def self.escalate_to_staff(message:, session_id:)
    # TODO: Create support ticket in staff inbox
    # For now, log the escalation
    Rails.logger.info("Support chat escalated - Session: #{session_id}, Message: #{message}")
    
    # In production, this would:
    # 1. Create a SupportTicket record
    # 2. Send notification to staff inbox
    # 3. Log in audit trail
  end

  def self.create_escalation_ticket(message, session_id)
    # TODO: Create actual support ticket
    # For now, return a mock ID
    SecureRandom.uuid
  end
end

