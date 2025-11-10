module Queries
  class OnboardingSession < BaseQuery
    description "Get an onboarding session by ID"

    argument :id, ID, required: true

    type Types::OnboardingSessionType, null: true

    def resolve(id:)
      parent = context[:current_user]
      
      return nil unless parent

      session = parent.onboarding_sessions.find_by(id: id)

      if session
        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'read',
          entity: session
        )
      end

      session
    end
  end
end

