module Mutations
  class BookAppointment < BaseMutation
    description "Book a therapy appointment"

    argument :input, Types::Inputs::BookAppointmentInput, required: true

    field :appointment, Types::AppointmentType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { appointment: nil, errors: ["Session not found"] }
      end

      student = session.students.first
      
      unless student
        return { appointment: nil, errors: ["Student not found"] }
      end

      # Create appointment
      appointment = Appointment.new(
        onboarding_session: session,
        student: student,
        therapist_id: input.therapist_id,
        scheduled_at: input.scheduled_at,
        duration_minutes: input.duration_minutes || 50,
        status: 'scheduled'
      )

      if appointment.save
        # Update session status
        session.update(status: 'completed')

        # Send notification (async via Sidekiq)
        SendAppointmentConfirmationJob.perform_later(appointment.id)

        # Log audit trail
        AuditLog.log_access(
          actor: current_user,
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

