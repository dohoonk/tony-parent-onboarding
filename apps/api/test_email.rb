#!/usr/bin/env ruby
# frozen_string_literal: true

# Quick test script to verify email configuration
# Usage: rails runner test_email.rb

puts "\n🧪 Testing Email Configuration...\n\n"

# Check environment variables
puts "1️⃣ Checking environment variables..."
sendgrid_key = ENV['SENDGRID_API_KEY']
from_email = ENV['SENDGRID_FROM_EMAIL'] || 'hello@daybreakhealth.com'

if sendgrid_key.present?
  puts "   ✅ SENDGRID_API_KEY is set (#{sendgrid_key[0..10]}...)"
else
  puts "   ❌ SENDGRID_API_KEY is not set!"
  puts "   Add it to apps/api/.env: SENDGRID_API_KEY=SG.your-key-here"
  exit 1
end

puts "   ✅ FROM email: #{from_email}"

# Check ActionMailer configuration
puts "\n2️⃣ Checking ActionMailer configuration..."
puts "   Delivery method: #{ActionMailer::Base.delivery_method}"
puts "   Perform deliveries: #{ActionMailer::Base.perform_deliveries}"
puts "   Raise errors: #{ActionMailer::Base.raise_delivery_errors}"

if ActionMailer::Base.smtp_settings.present?
  puts "   SMTP settings:"
  puts "     - Address: #{ActionMailer::Base.smtp_settings[:address]}"
  puts "     - Port: #{ActionMailer::Base.smtp_settings[:port]}"
  puts "     - Domain: #{ActionMailer::Base.smtp_settings[:domain]}"
  puts "     - Username: #{ActionMailer::Base.smtp_settings[:user_name]}"
  puts "     - Password: #{ActionMailer::Base.smtp_settings[:password].present? ? '[SET]' : '[NOT SET]'}"
end

# Find or create a test appointment
puts "\n3️⃣ Finding test appointment..."
appointment = Appointment.includes(:onboarding_session, :student, :therapist).last

unless appointment
  puts "   ❌ No appointments found in database!"
  puts "   Create a test appointment first by going through the onboarding flow."
  exit 1
end

parent = appointment.onboarding_session.parent
puts "   ✅ Found appointment ##{appointment.id}"
puts "   Parent: #{parent.first_name} #{parent.last_name} (#{parent.email})"
puts "   Student: #{appointment.student.first_name}"
puts "   Therapist: #{appointment.therapist.display_name}"

# Ask for confirmation
print "\n4️⃣ Send test email to #{parent.email}? (y/n): "
response = $stdin.gets.chomp.downcase

unless ['y', 'yes'].include?(response)
  puts "   ⏭️  Test cancelled."
  exit 0
end

# Send the email
puts "\n5️⃣ Sending test email..."
begin
  email = AppointmentMailer.confirmation_email(appointment.id)
  email.deliver_now
  
  puts "\n   ✅ SUCCESS! Email sent to #{parent.email}"
  puts "\n📧 Email Details:"
  puts "   From: #{email.from.join(', ')}"
  puts "   To: #{email.to.join(', ')}"
  puts "   Subject: #{email.subject}"
  
  puts "\n💡 Next Steps:"
  puts "   1. Check #{parent.email} inbox"
  puts "   2. Look in spam folder if not in inbox"
  puts "   3. Check SendGrid dashboard: https://app.sendgrid.com/email_activity"
  puts "   4. View logs: tail -f log/development.log | grep -i email"
  
rescue StandardError => e
  puts "\n   ❌ FAILED to send email!"
  puts "   Error: #{e.message}"
  puts "\n🔍 Troubleshooting:"
  puts "   1. Verify SENDGRID_API_KEY is correct"
  puts "   2. Check SendGrid account is active"
  puts "   3. Verify sender email (#{from_email}) in SendGrid"
  puts "   4. Check logs: tail -f log/development.log | grep -i error"
  exit 1
end

puts "\n✨ Email test complete!\n\n"

