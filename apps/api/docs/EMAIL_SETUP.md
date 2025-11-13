# Email Setup Guide

## Overview
Appointment confirmation emails are automatically sent when a parent confirms their therapist and books an appointment. The email matches the "You're all set!" confirmation screen design.

## Email Flow

```
Parent confirms therapist
       ↓
BookAppointment mutation
       ↓
Appointment created & saved
       ↓
SendAppointmentConfirmationJob.perform_later(appointment.id)
       ↓
AppointmentMailer.confirmation_email(appointment_id).deliver_now
       ↓
Email sent to parent's email address
```

## Files

### Mailer
- **`app/mailers/appointment_mailer.rb`**: Main mailer class with confirmation_email method
- **`app/mailers/application_mailer.rb`**: Base mailer class (sets default from address)

### Email Templates
- **`app/views/appointment_mailer/confirmation_email.html.erb`**: HTML email template (styled to match UI)
- **`app/views/appointment_mailer/confirmation_email.text.erb`**: Plain text fallback

### Background Job
- **`app/jobs/send_appointment_confirmation_job.rb`**: Sidekiq job that triggers email sending

### Triggered By
- **`app/graphql/mutations/book_appointment.rb`**: Queues the job after successful appointment creation

## Email Content

The confirmation email includes:

### Header Section
- ✅ "You're confirmed" badge
- Parent's first name greeting
- Student's name + therapist name

### Session Details
- Therapist name & credentials
- Scheduled date & time
- Languages spoken
- Focus areas/specialties
- Estimated cost (from insurance data)

### What Happens Next
1. Confirmation sent (calendar invites within 24h)
2. Therapist intro (2-3 days before)
3. Final reminder (24 hours before with video link)

### Timeline Overview
- Today → 24 hours → 2-3 days before → 24 hours before → Session day

### Reassurance
- "75% of families report huge improvement"
- "Most families notice meaningful changes after just one session"

### Support Information
- Support email
- Support phone
- Response time expectations

## Environment Variables

### Required
```env
# Email Service (SendGrid recommended)
SENDGRID_API_KEY=SG.your-api-key-here
SENDGRID_FROM_EMAIL=hello@daybreakhealth.com

# Support Contact
SUPPORT_EMAIL=support@daybreakhealth.com
SUPPORT_PHONE=1-800-DAYBREAK
```

### Optional (for different email providers)
```env
# If using SMTP instead of SendGrid
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_DOMAIN=daybreakhealth.com
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key
SMTP_AUTHENTICATION=plain
SMTP_ENABLE_STARTTLS_AUTO=true
```

## Configuration

### Development (uses letter_opener)
Emails open in browser instead of actually sending:

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :letter_opener
config.action_mailer.perform_deliveries = true
```

### Production (uses SendGrid)
```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'] || 'smtp.sendgrid.net',
  port: ENV['SMTP_PORT'] || 587,
  domain: ENV['SMTP_DOMAIN'] || 'daybreakhealth.com',
  user_name: ENV['SMTP_USERNAME'] || 'apikey',
  password: ENV['SMTP_PASSWORD'] || ENV['SENDGRID_API_KEY'],
  authentication: :plain,
  enable_starttls_auto: true
}
```

## SendGrid Setup

### 1. Create SendGrid Account
1. Sign up at https://sendgrid.com
2. Verify your email
3. Complete sender authentication

### 2. Create API Key
1. Go to Settings → API Keys
2. Create API Key with "Mail Send" permissions
3. Copy the API key (shown only once!)

### 3. Verify Domain (Recommended for Production)
1. Settings → Sender Authentication → Verify Domain
2. Add DNS records to your domain
3. Wait for verification (up to 48 hours)

### 4. Add to Environment
```bash
# .env or Heroku config
heroku config:set SENDGRID_API_KEY=SG.your-key-here
heroku config:set SENDGRID_FROM_EMAIL=hello@yourdomain.com
```

## Testing

### Test in Development
```ruby
# Rails console
appointment = Appointment.last
AppointmentMailer.confirmation_email(appointment.id).deliver_now

# Opens in browser via letter_opener
```

### Test via Background Job
```ruby
# Rails console
appointment = Appointment.last
SendAppointmentConfirmationJob.perform_now(appointment.id)
```

### Test in Staging/Production
```bash
# Trigger via GraphQL mutation (creates real appointment)
mutation {
  bookAppointment(input: {
    sessionId: "...",
    therapistId: "...",
    scheduledAt: "2025-01-15T14:00:00Z",
    durationMinutes: 50
  }) {
    appointment {
      id
    }
    errors
  }
}

# Check logs
heroku logs --tail | grep "Email successfully sent"
```

## Debugging

### Email Not Sending
1. **Check Sidekiq is running**: `bundle exec sidekiq`
2. **Check logs**: `tail -f log/development.log | grep -i email`
3. **Check SendGrid dashboard**: Sent emails should appear in Activity Feed
4. **Verify API key**: Test with curl:
```bash
curl --request POST \
  --url https://api.sendgrid.com/v3/mail/send \
  --header "Authorization: Bearer $SENDGRID_API_KEY" \
  --header 'Content-Type: application/json' \
  --data '{...}'
```

### Email Goes to Spam
1. **Verify sender domain** in SendGrid
2. **Add SPF/DKIM records** to your DNS
3. **Use consistent from address**
4. **Avoid spam trigger words** in subject/body

### Email Looks Broken
1. **Test in multiple clients** (Gmail, Outlook, Apple Mail)
2. **Use email testing service**: Litmus or Email on Acid
3. **Check HTML/CSS**: Inline styles are required for email
4. **Validate HTML**: Use W3C validator

## Customization

### Changing Email Content
Edit the ERB templates:
- HTML: `app/views/appointment_mailer/confirmation_email.html.erb`
- Text: `app/views/appointment_mailer/confirmation_email.text.erb`

### Changing Email Styling
Update inline styles in the HTML template. Email CSS has limited support:
- ✅ Inline styles
- ✅ Basic CSS (colors, fonts, margins)
- ❌ External stylesheets
- ❌ CSS Grid/Flexbox (limited support)
- ❌ JavaScript

### Adding Variables
1. Add to mailer method:
```ruby
# app/mailers/appointment_mailer.rb
@new_variable = "value"
```

2. Use in template:
```erb
<%= @new_variable %>
```

## Future Enhancements

### Planned Features
- [ ] SMS confirmations via Twilio
- [ ] Calendar file attachments (.ics)
- [ ] Therapist intro email (2-3 days before)
- [ ] Reminder email (24 hours before)
- [ ] Post-session follow-up email
- [ ] Email preference management
- [ ] Unsubscribe functionality
- [ ] Email analytics tracking

### Email Types to Add
- Welcome email (after signup)
- Insurance verification email
- Rescheduling confirmation
- Cancellation confirmation
- Session summary email (post-session)
- Progress report email (monthly)

## Security & Compliance

### Best Practices
- ✅ Don't include sensitive medical info in subject lines
- ✅ Use HTTPS for all links
- ✅ Provide unsubscribe option (required by CAN-SPAM)
- ✅ Include physical mailing address (required by CAN-SPAM)
- ✅ Honor opt-out requests within 10 days
- ✅ Keep logs of email sending for audit

### HIPAA Considerations
- Emails should not contain PHI (Protected Health Information)
- Use generic language: "your appointment" not "therapy for anxiety"
- Patient portal links should require authentication
- Consider encrypting sensitive emails

### Data Retention
- Keep email send logs for 7 years (HIPAA requirement)
- Store opt-out preferences permanently
- Delete old email content after retention period

## Support

For questions or issues:
- **Dev Team**: #engineering-support
- **SendGrid Docs**: https://docs.sendgrid.com/
- **Rails Guides**: https://guides.rubyonrails.org/action_mailer_basics.html

