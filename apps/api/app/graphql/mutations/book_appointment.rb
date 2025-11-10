module Mutations
  class BookAppointment < BaseMutation
    description "Book a therapy appointment"

    argument :input, Types::Inputs::BookAppointmentInput, required: true

    field :appointment, Types::AppointmentType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { appointment: nil, errors: ["Authentication required"] }
      end

      session = parent.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { appointment: nil, errors: ["Session not found"] }
      end

      # Create appointment
      appointment = Appointment.new(
        onboarding_session: session,
        student: session.student,
        therapist_id: input.therapist_id,
        scheduled_at: input.scheduled_at,
        duration_minutes: input.duration_minutes || 50,
        status: 'scheduled'
      )

      if appointment.save
        # Update session to completed if this is the final step
        if session.current_step >= 5
          session.update(status: 'completed')
        end

        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: appointment,
          after: appointment.attributes
        )

        { appointment: appointment, errors: [] }
      else
        { appointment: nil, errors: appointment.errors.full_messages }
      end
    end
  end
end

