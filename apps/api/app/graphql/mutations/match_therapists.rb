module Mutations
  class MatchTherapists < BaseMutation
    description "Match therapists based on student needs and availability"

    argument :session_id, ID, required: true
    argument :availability_window_id, ID, required: true

    field :matches, [Types::TherapistMatchType], null: false
    field :errors, [String], null: false

    def resolve(session_id:, availability_window_id:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: session_id)
      
      unless session
        return { matches: [], errors: ["Session not found"] }
      end

      student = session.students.first
      
      unless student
        return { matches: [], errors: ["Student not found"] }
      end

      availability_window = AvailabilityWindow.find_by(id: availability_window_id)
      
      unless availability_window
        return { matches: [], errors: ["Availability window not found"] }
      end

      # Get matches
      matches = TherapistMatchingService.match(
        student: student,
        availability_window: availability_window,
        limit: 4
      )

      # Log audit trail
      AuditLog.log_access(
        actor: current_user,
        action: 'read',
        entity: session,
        after: { therapist_matches_requested: matches.length }
      )

      { matches: matches, errors: [] }
    rescue StandardError => e
      Rails.logger.error("Therapist matching failed: #{e.message}")
      { matches: [], errors: ["Failed to match therapists: #{e.message}"] }
    end
  end
end

