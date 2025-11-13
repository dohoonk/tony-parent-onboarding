class AppointmentMailer < ApplicationMailer
  default from: ENV.fetch('SENDGRID_FROM_EMAIL', 'hello@daybreakhealth.com')

  def confirmation_email(appointment_id)
    @appointment = Appointment.find(appointment_id)
    @parent = @appointment.onboarding_session.parent
    @student = @appointment.student
    @therapist = @appointment.therapist
    @session = @appointment.onboarding_session

    # Extract scheduling details
    @scheduled_date = @appointment.scheduled_at&.strftime('%A, %B %d, %Y')
    @scheduled_time = @appointment.scheduled_at&.strftime('%I:%M %p %Z')
    @time_window = extract_time_window(@appointment.scheduled_at)
    
    # Get therapist details
    @therapist_name = @therapist.display_name
    @therapist_bio = @therapist.bio
    @therapist_specialties = @therapist.specialties&.take(3)&.join(', ')
    @therapist_languages = @therapist.languages&.join(', ')
    @therapist_credentials = extract_credential(@therapist.credentials&.first)
    @therapist_experience = @therapist.years_of_experience

    # Cost information
    @estimated_cost = format_estimated_cost(@session)

    # Parent and student info
    @parent_name = @parent.first_name
    @student_name = @student.first_name

    # Support contact
    @support_email = ENV.fetch('SUPPORT_EMAIL', 'support@daybreakhealth.com')
    @support_phone = ENV.fetch('SUPPORT_PHONE', '1-800-DAYBREAK')

    mail(
      to: @parent.email,
      subject: "You're all set! First session with #{@therapist_name} confirmed"
    )
  end

  private

  def extract_time_window(scheduled_at)
    return nil unless scheduled_at
    
    hour = scheduled_at.hour
    case hour
    when 6..11
      'morning'
    when 12..16
      'afternoon'
    when 17..20
      'evening'
    else
      'evening'
    end
  end

  def extract_credential(credential_string)
    return 'Licensed Therapist' unless credential_string.present?
    
    # Extract just the credential abbreviation (e.g., "LCSW", "PsyD")
    credential_string.split(',').first&.strip || 'Licensed Therapist'
  end

  def format_estimated_cost(session)
    # Check if there's cost estimate data
    if session.data.dig('insurance', 'estimatedCopay').present?
      copay = session.data.dig('insurance', 'estimatedCopay')
      "$#{copay} per session (estimated copay)"
    elsif session.data.dig('insurance', 'carrierName').present?
      "Covered by #{session.data.dig('insurance', 'carrierName')} (copay TBD)"
    else
      'Cost to be determined'
    end
  end
end

