#!/usr/bin/env ruby
# Export existing therapists from the database to a Ruby seed format
# Run this in Railway console: rails runner scripts/export_existing_therapists.rb

puts "=" * 80
puts "EXISTING THERAPIST DATA EXPORT"
puts "=" * 80
puts ""

therapist_count = Therapist.count
puts "Found #{therapist_count} therapist(s) in the database"
puts ""

if therapist_count.zero?
  puts "❌ No therapists found in the database."
  puts "The database is empty - you can run db:seed to create demo data."
  exit
end

puts "=" * 80
puts "THERAPIST DATA (Copy this to db/seeds.rb)"
puts "=" * 80
puts ""

Therapist.all.each_with_index do |t, index|
  puts "# Therapist #{index + 1}"
  puts "Therapist.create!("
  
  attributes = {
    email: t.email,
    phone: t.phone,
    first_name: t.first_name,
    middle_name: t.middle_name,
    last_name: t.last_name,
    preferred_name: t.preferred_name,
    preferred_pronoun: t.preferred_pronoun,
    title: t.title,
    birthdate: t.birthdate&.inspect,
    preferred_language: t.preferred_language,
    legal_gender: t.legal_gender,
    npi_number: t.npi_number,
    licenses: t.licenses.inspect,
    licensed_states: t.licensed_states.inspect,
    primary_state: t.primary_state,
    states_active: t.states_active.inspect,
    specialties: t.specialties.inspect,
    modalities: t.modalities.inspect,
    care_languages: t.care_languages.inspect,
    employment_type: t.employment_type,
    clinical_role: t.clinical_role,
    care_provider_role: t.care_provider_role,
    care_provider_status: t.care_provider_status,
    clinical_associate: t.clinical_associate,
    bio: t.bio&.inspect,
    capacity_total: t.capacity_total,
    capacity_filled: t.capacity_filled,
    capacity_available: t.capacity_available,
    capacity_total_daybreak: t.capacity_total_daybreak,
    capacity_filled_daybreak: t.capacity_filled_daybreak,
    capacity_available_daybreak: t.capacity_available_daybreak,
    account_status: t.account_status,
    active: t.active
  }
  
  attributes.each do |key, value|
    next if value.nil?
    puts "  #{key}: #{value},"
  end
  
  puts ")"
  puts ""
end

# Export availability windows
puts "=" * 80
puts "AVAILABILITY WINDOWS"
puts "=" * 80
puts ""

AvailabilityWindow.all.each_with_index do |av, index|
  therapist = av.owner
  therapist_identifier = therapist ? "\"#{therapist.email}\"" : "nil"
  
  puts "# Availability Window #{index + 1}"
  puts "therapist = Therapist.find_by(email: #{therapist_identifier})"
  puts "therapist&.availability_windows&.create!("
  puts "  start_date: Date.parse('#{av.start_date}'),"
  puts "  end_date: #{av.end_date ? "Date.parse('#{av.end_date}')" : 'nil'},"
  puts "  timezone: #{av.timezone.inspect},"
  puts "  availability_json: #{av.availability_json.inspect}"
  puts ")"
  puts ""
end

# Export insurance plans
puts "=" * 80
puts "CREDENTIALED INSURANCES"
puts "=" * 80
puts ""

CredentialedInsurance.all.each_with_index do |ins, index|
  puts "# Insurance #{index + 1}"
  puts "CredentialedInsurance.create!("
  puts "  name: #{ins.name.inspect},"
  puts "  country: #{ins.country.inspect},"
  puts "  state: #{ins.state.inspect},"
  puts "  network_status: #{ins.network_status},"
  puts "  associates_allowed: #{ins.associates_allowed}"
  puts ")"
  puts ""
end

# Export therapist-insurance links
puts "=" * 80
puts "THERAPIST-INSURANCE LINKS"
puts "=" * 80
puts ""

ClinicianCredentialedInsurance.includes(:therapist, :credentialed_insurance).each_with_index do |link, index|
  therapist_email = link.therapist&.email
  insurance_name = link.credentialed_insurance&.name
  insurance_state = link.credentialed_insurance&.state
  
  puts "# Link #{index + 1}"
  puts "therapist = Therapist.find_by(email: #{therapist_email.inspect})"
  puts "insurance = CredentialedInsurance.find_by(name: #{insurance_name.inspect}, state: #{insurance_state.inspect})"
  puts "therapist&.clinician_credentialed_insurances&.create!(credentialed_insurance: insurance) if therapist && insurance"
  puts ""
end

puts "=" * 80
puts "EXPORT COMPLETE"
puts "=" * 80
puts ""
puts "📋 Summary:"
puts "  - Therapists: #{Therapist.count}"
puts "  - Availability Windows: #{AvailabilityWindow.count}"
puts "  - Insurance Plans: #{CredentialedInsurance.count}"
puts "  - Therapist-Insurance Links: #{ClinicianCredentialedInsurance.count}"
puts ""
puts "✅ Copy the output above and add it to db/seeds.rb"

