module Mutations
  class StartOnboarding < BaseMutation
    description "Start a new onboarding session for a student"

    argument :input, Types::Inputs::StartOnboardingInput, required: true

    field :session, Types::OnboardingSessionType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { session: nil, errors: ["Authentication required"] }
      end

      student = parent.students.find_by(id: input.student_id)
      
      unless student
        return { session: nil, errors: ["Student not found"] }
      end

      # Check for existing active session
      existing_session = OnboardingSession.where(
        parent: parent,
        student: student,
        status: ['draft', 'active']
      ).first

      if existing_session
        return { session: existing_session, errors: [] }
      end

      # Create new session
      session = OnboardingSession.new(
        parent: parent,
        student: student,
        status: 'active',
        current_step: 1
      )

      if session.save
        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: session,
          after: session.attributes
        )

        { session: session, errors: [] }
      else
        { session: nil, errors: session.errors.full_messages }
      end
    end
  end
end

