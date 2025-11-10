class SendAppointmentConfirmationJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find(appointment_id)
    parent = appointment.onboarding_session.parent

    # Send email notification
    # TODO: Integrate with Postmark or similar service
    Rails.logger.info("Sending appointment confirmation to #{parent.email} for appointment #{appointment_id}")

    # Send SMS notification if phone number available
    if parent.phone.present?
      # TODO: Integrate with Twilio
      Rails.logger.info("Sending SMS confirmation to #{parent.phone} for appointment #{appointment_id}")
    end

    # Log notification in audit log
    AuditLog.log_access(
      actor: parent,
      action: 'notify',
      entity: appointment,
      after: { notification_type: 'appointment_confirmation', sent_at: Time.current }
    )
  rescue StandardError => e
    Rails.logger.error("Failed to send appointment confirmation: #{e.message}")
    raise
  end
end

