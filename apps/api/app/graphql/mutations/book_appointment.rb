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

      # Validate therapist exists
      therapist = Therapist.find_by(id: input.therapist_id)
      
      unless therapist
        return { appointment: nil, errors: ["Therapist not found"] }
      end

      # Check therapist has capacity
      unless therapist.has_capacity?
        return { appointment: nil, errors: ["Therapist is at full capacity"] }
      end

      # Check therapist availability (basic check - can be enhanced)
      scheduled_time = input.scheduled_at
      if scheduled_time.present?
        # Check if therapist has availability window that includes this time
        day_name = scheduled_time.strftime('%A')
        time_str = scheduled_time.strftime('%H:%M:%S')
        
        therapist_available = therapist.availability_windows.any? do |window|
          window.uses_json_format? && window.available_at_time?(day_name, time_str)
        end
        
        unless therapist_available
          return { appointment: nil, errors: ["Therapist is not available at the requested time"] }
        end
      end

      # Create appointment
      appointment = Appointment.new(
        onboarding_session: session,
        student: student,
        therapist: therapist,
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

