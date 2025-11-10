module Mutations
  class SendOnboardingSummary < BaseMutation
    description "Send post-onboarding summary via email and SMS"

    argument :session_id, ID, required: true

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(session_id:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: session_id)
      
      unless session
        return { success: false, errors: ["Session not found"] }
      end

      # Send notifications asynchronously
      SendOnboardingSummaryJob.perform_later(session.id)

      { success: true, errors: [] }
    rescue StandardError => e
      Rails.logger.error("Send summary failed: #{e.message}")
      { success: false, errors: ["Failed to send summary: #{e.message}"] }
    end
  end
end

