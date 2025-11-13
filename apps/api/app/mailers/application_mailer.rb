class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('SENDGRID_FROM_EMAIL', 'hello@daybreakhealth.com')
  layout "mailer"
end

