module Mutations
  class ExtractIntakeSummary < BaseMutation
    description "Extract structured summary from intake conversation"

    argument :session_id, ID, required: true

    field :summary, Types::IntakeSummaryType, null: false
    field :errors, [String], null: false

    def resolve(session_id:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: session_id)
      
      unless session
        return { summary: nil, errors: ["Session not found"] }
      end

      # Extract summary
      summary = IntakeSummaryService.extract_summary(session)

      # Log audit trail
      AuditLog.log_access(
        actor: current_user,
        action: 'write',
        entity: summary
      )

      { summary: summary, errors: [] }
    rescue StandardError => e
      Rails.logger.error("Summary extraction error: #{e.message}")
      { summary: nil, errors: ["Failed to extract summary: #{e.message}"] }
    end
  end
end

