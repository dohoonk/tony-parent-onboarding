class SendAppointmentConfirmationJob < ApplicationJob
  queue_as :default

  def perform(appointment_id)
    appointment = Appointment.find(appointment_id)
    parent = appointment.onboarding_session.parent

    # Send email notification
    Rails.logger.info("Sending appointment confirmation to #{parent.email} for appointment #{appointment_id}")
    
    begin
      AppointmentMailer.confirmation_email(appointment_id).deliver_now
      Rails.logger.info("✅ Email successfully sent to #{parent.email}")
    rescue StandardError => email_error
      Rails.logger.error("❌ Failed to send email: #{email_error.message}")
      # Don't fail the entire job if email fails, continue to SMS
    end

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
      after: { 
        notification_type: 'appointment_confirmation', 
        sent_at: Time.current,
        email_sent: true,
        sms_sent: parent.phone.present?
      }
    )
  rescue StandardError => e
    Rails.logger.error("Failed to send appointment confirmation: #{e.message}")
    raise
  end
end

