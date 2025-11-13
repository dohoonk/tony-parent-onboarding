#!/usr/bin/env ruby
# Inspect current database contents
# Run this in Railway console: rails runner scripts/inspect_database.rb

puts "=" * 80
puts "DATABASE INSPECTION REPORT"
puts "=" * 80
puts ""

# Therapists
puts "👨‍⚕️ THERAPISTS (#{Therapist.count})"
puts "-" * 80
if Therapist.any?
  Therapist.all.each_with_index do |t, index|
    puts ""
    puts "#{index + 1}. #{t.display_name} (#{t.email})"
    puts "   Title: #{t.title}"
    puts "   Licensed States: #{t.licensed_states.join(', ')}" if t.licensed_states.any?
    puts "   Specialties: #{t.specialties.join(', ')}" if t.specialties.any?
    puts "   Languages: #{t.care_languages.join(', ')}" if t.care_languages.any?
    puts "   Capacity: #{t.capacity_filled}/#{t.capacity_total} (#{t.capacity_available} available)"
    puts "   Status: #{t.active ? '✅ Active' : '❌ Inactive'}"
    
    # Availability
    av_count = t.availability_windows.count
    if av_count > 0
      puts "   Availability Windows: #{av_count}"
      t.availability_windows.each do |av|
        puts "     - #{av.start_date} to #{av.end_date || 'ongoing'} (#{av.timezone})"
        if av.availability_json.present?
          av.availability_json.each do |day, times|
            puts "       #{day.capitalize}: #{times.join(', ')}"
          end
        end
      end
    else
      puts "   ⚠️  No availability windows"
    end
    
    # Insurance
    ins_count = t.credentialed_insurances.count
    if ins_count > 0
      puts "   Accepted Insurance: #{ins_count} plans"
      t.credentialed_insurances.each do |ins|
        puts "     - #{ins.name} (#{ins.state})"
      end
    else
      puts "   ⚠️  No insurance credentials"
    end
  end
else
  puts "❌ No therapists found"
end

puts ""
puts "=" * 80

# Parents
puts ""
puts "👪 PARENTS (#{Parent.count})"
puts "-" * 80
if Parent.any?
  Parent.limit(5).each_with_index do |p, index|
    puts "#{index + 1}. #{p.first_name} #{p.last_name} (#{p.email})"
    student_count = Student.where(parent_id: p.id).count
    puts "   Students: #{student_count}"
  end
  puts "(Showing first 5)" if Parent.count > 5
else
  puts "❌ No parents found"
end

puts ""
puts "=" * 80

# Students
puts ""
puts "🎓 STUDENTS (#{Student.count})"
puts "-" * 80
if Student.any?
  Student.limit(5).each_with_index do |s, index|
    puts "#{index + 1}. #{s.first_name} #{s.last_name}"
    puts "   Grade: #{s.grade}, DOB: #{s.date_of_birth}"
  end
  puts "(Showing first 5)" if Student.count > 5
else
  puts "❌ No students found"
end

puts ""
puts "=" * 80

# Onboarding Sessions
puts ""
puts "📝 ONBOARDING SESSIONS (#{OnboardingSession.count})"
puts "-" * 80
if OnboardingSession.any?
  statuses = OnboardingSession.group(:status).count
  statuses.each do |status, count|
    puts "   #{status}: #{count}"
  end
else
  puts "❌ No onboarding sessions found"
end

puts ""
puts "=" * 80

# Appointments
puts ""
puts "📅 APPOINTMENTS (#{Appointment.count})"
puts "-" * 80
if Appointment.any?
  statuses = Appointment.group(:status).count
  statuses.each do |status, count|
    puts "   #{status}: #{count}"
  end
else
  puts "❌ No appointments found"
end

puts ""
puts "=" * 80

# Insurance
puts ""
puts "🏥 INSURANCE PLANS (#{CredentialedInsurance.count})"
puts "-" * 80
if CredentialedInsurance.any?
  CredentialedInsurance.all.each_with_index do |ins, index|
    puts "#{index + 1}. #{ins.name} (#{ins.state})"
    puts "   Network Status: #{ins.network_status}"
    therapist_count = ins.clinician_credentialed_insurances.count
    puts "   Therapists: #{therapist_count}"
  end
else
  puts "❌ No insurance plans found"
end

puts ""
puts "=" * 80

# Screeners
puts ""
puts "📋 SCREENERS (#{Screener.count})"
puts "-" * 80
if Screener.any?
  Screener.all.each_with_index do |s, index|
    puts "#{index + 1}. #{s.title} (#{s.key})"
    puts "   Version: #{s.version}"
    response_count = ScreenerResponse.where(screener_id: s.id).count
    puts "   Responses: #{response_count}"
  end
else
  puts "❌ No screeners found"
end

puts ""
puts "=" * 80
puts "SUMMARY"
puts "=" * 80
puts ""
puts "Total Records:"
puts "  - Therapists: #{Therapist.count}"
puts "  - Parents: #{Parent.count}"
puts "  - Students: #{Student.count}"
puts "  - Onboarding Sessions: #{OnboardingSession.count}"
puts "  - Appointments: #{Appointment.count}"
puts "  - Insurance Plans: #{CredentialedInsurance.count}"
puts "  - Screeners: #{Screener.count}"
puts ""

if Therapist.count.zero?
  puts "💡 TIP: Run 'rails db:seed' to create demo data!"
end

puts "=" * 80

