class SendOnboardingSummaryJob < ApplicationJob
  queue_as :default

  def perform(session_id)
    session = OnboardingSession.find(session_id)
    parent = session.parent
    appointment = session.appointments.first

    # Generate summary content
    summary_content = generate_summary(session, appointment)

    # Send email notification
    send_email_notification(parent, summary_content)

    # Send SMS notification if phone available
    if parent.phone.present?
      send_sms_notification(parent, summary_content)
    end

    # Log notification in audit log
    AuditLog.log_access(
      actor: parent,
      action: 'notify',
      entity: session,
      after: {
        notification_type: 'onboarding_summary',
        sent_at: Time.current,
        channels: ['email', parent.phone.present? ? 'sms' : nil].compact
      }
    )
  rescue StandardError => e
    Rails.logger.error("Failed to send onboarding summary: #{e.message}")
    raise
  end

  private

  def generate_summary(session, appointment)
    {
      parent_name: "#{session.parent.first_name} #{session.parent.last_name}",
      student_name: session.students.first&.full_name || 'Your child',
      appointment_date: appointment&.scheduled_at&.strftime('%B %d, %Y'),
      appointment_time: appointment&.scheduled_at&.strftime('%I:%M %p'),
      therapist_name: appointment&.therapist&.display_name || 'To be assigned',
      estimated_cost: session.cost_estimate ? "$#{session.cost_estimate.min_cost} - $#{session.cost_estimate.max_cost} per session" : 'To be determined',
      next_steps: [
        'You will receive a confirmation email and SMS shortly',
        'Your therapist will reach out before your first session',
        'Complete any remaining paperwork if needed',
        'Prepare for your first session by thinking about goals'
      ]
    }
  end

  def send_email_notification(parent, summary)
    # TODO: Integrate with Postmark or similar email service
    Rails.logger.info("Sending onboarding summary email to #{parent.email}")
    
    # In production, this would use ActionMailer:
    # OnboardingMailer.summary_email(parent, summary).deliver_now
  end

  def send_sms_notification(parent, summary)
    # TODO: Integrate with Twilio
    Rails.logger.info("Sending onboarding summary SMS to #{parent.phone}")
    
    # In production, this would use Twilio:
    # TwilioService.send_sms(
    #   to: parent.phone,
    #   body: "Thank you for completing onboarding! Your appointment is scheduled for #{summary[:appointment_date]} at #{summary[:appointment_time]}."
    # )
  end
end

