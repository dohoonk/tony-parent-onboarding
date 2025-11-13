# Demo Data Seeds for Parent Onboarding App
# Run this with: rails db:seed

puts "🌱 Starting seed process..."

# Clean up existing demo data (optional - comment out if you want to keep existing data)
puts "🧹 Cleaning up existing demo data..."
Therapist.destroy_all
CredentialedInsurance.destroy_all

# Create Demo Therapists
puts "👨‍⚕️ Creating demo therapists..."

therapist1 = Therapist.create!(
  email: "dr.sarah.smith@daybreakhealth.com",
  phone: "+1-555-0101",
  first_name: "Sarah",
  last_name: "Smith",
  preferred_name: "Dr. Sarah",
  title: "PhD, LMFT",
  birthdate: Date.new(1985, 6, 15),
  preferred_language: "en",
  legal_gender: "Female",
  npi_number: "1234567890",
  licenses: ["LMFT-12345", "LPC-67890"],
  licensed_states: ["CA", "NY", "TX"],
  primary_state: "CA",
  states_active: ["CA", "NY", "TX"],
  specialties: [
    "Anxiety & Depression",
    "Family Therapy",
    "Adolescent Counseling",
    "Trauma-Informed Care"
  ],
  modalities: [
    "Cognitive Behavioral Therapy (CBT)",
    "Dialectical Behavior Therapy (DBT)",
    "Family Systems Therapy"
  ],
  care_languages: ["English", "Spanish"],
  employment_type: "Full-time",
  clinical_role: "Therapist",
  care_provider_role: "Lead Therapist",
  care_provider_status: "Active",
  clinical_associate: false,
  bio: "Dr. Sarah Smith is a licensed marriage and family therapist with over 10 years of experience working with children, adolescents, and families. She specializes in anxiety, depression, and trauma-informed care. Dr. Smith is passionate about creating a safe, supportive environment where young people can explore their feelings and develop healthy coping strategies.",
  capacity_total: 15,
  capacity_filled: 5,
  capacity_available: 10,
  capacity_total_daybreak: 15,
  capacity_filled_daybreak: 5,
  capacity_available_daybreak: 10,
  account_status: "active",
  active: true
)

therapist2 = Therapist.create!(
  email: "dr.michael.chen@daybreakhealth.com",
  phone: "+1-555-0102",
  first_name: "Michael",
  last_name: "Chen",
  preferred_name: "Dr. Mike",
  title: "PsyD",
  birthdate: Date.new(1980, 3, 22),
  preferred_language: "en",
  legal_gender: "Male",
  npi_number: "9876543210",
  licenses: ["PSY-54321"],
  licensed_states: ["CA", "WA", "OR"],
  primary_state: "CA",
  states_active: ["CA", "WA"],
  specialties: [
    "ADHD & Executive Function",
    "Behavioral Issues",
    "Social Skills Development",
    "Parent Coaching"
  ],
  modalities: [
    "Play Therapy",
    "Cognitive Behavioral Therapy (CBT)",
    "Parent-Child Interaction Therapy (PCIT)"
  ],
  care_languages: ["English", "Mandarin"],
  employment_type: "Full-time",
  clinical_role: "Therapist",
  care_provider_role: "Senior Therapist",
  care_provider_status: "Active",
  clinical_associate: false,
  bio: "Dr. Michael Chen is a clinical psychologist specializing in childhood ADHD, behavioral challenges, and social skills development. With a warm, engaging approach, he helps children build confidence and develop strategies for success both at home and in school.",
  capacity_total: 20,
  capacity_filled: 12,
  capacity_available: 8,
  capacity_total_daybreak: 20,
  capacity_filled_daybreak: 12,
  capacity_available_daybreak: 8,
  account_status: "active",
  active: true
)

therapist3 = Therapist.create!(
  email: "dr.emily.rodriguez@daybreakhealth.com",
  phone: "+1-555-0103",
  first_name: "Emily",
  last_name: "Rodriguez",
  preferred_name: "Emily",
  title: "LCSW",
  birthdate: Date.new(1990, 9, 8),
  preferred_language: "en",
  legal_gender: "Female",
  npi_number: "5555555555",
  licenses: ["LCSW-98765"],
  licensed_states: ["CA", "NY"],
  primary_state: "NY",
  states_active: ["CA", "NY"],
  specialties: [
    "LGBTQ+ Youth Support",
    "Depression & Mood Disorders",
    "Self-Esteem & Identity",
    "School-Related Stress"
  ],
  modalities: [
    "Acceptance and Commitment Therapy (ACT)",
    "Mindfulness-Based Therapy",
    "Solution-Focused Brief Therapy"
  ],
  care_languages: ["English", "Spanish"],
  employment_type: "Full-time",
  clinical_role: "Therapist",
  care_provider_role: "Therapist",
  care_provider_status: "Active",
  clinical_associate: false,
  bio: "Emily Rodriguez is a licensed clinical social worker who is passionate about supporting LGBTQ+ youth and teens struggling with depression, identity issues, and school stress. She creates an affirming, nonjudgmental space where young people can be themselves.",
  capacity_total: 12,
  capacity_filled: 3,
  capacity_available: 9,
  capacity_total_daybreak: 12,
  capacity_filled_daybreak: 3,
  capacity_available_daybreak: 9,
  account_status: "active",
  active: true
)

puts "✅ Created #{Therapist.count} demo therapists"

# Create Availability Windows for Therapists
puts "📅 Creating availability windows..."

# Dr. Sarah - Available Monday, Wednesday, Friday
therapist1.availability_windows.create!(
  start_date: Date.today,
  end_date: Date.today + 3.months,
  timezone: "America/Los_Angeles",
  availability_json: {
    "monday" => ["09:00-12:00", "13:00-17:00"],
    "wednesday" => ["09:00-12:00", "13:00-17:00"],
    "friday" => ["09:00-12:00", "14:00-18:00"]
  }
)

# Dr. Mike - Available Tuesday, Thursday
therapist2.availability_windows.create!(
  start_date: Date.today,
  end_date: Date.today + 3.months,
  timezone: "America/Los_Angeles",
  availability_json: {
    "tuesday" => ["10:00-13:00", "14:00-19:00"],
    "thursday" => ["10:00-13:00", "14:00-19:00"]
  }
)

# Emily - Available Monday through Thursday
therapist3.availability_windows.create!(
  start_date: Date.today,
  end_date: Date.today + 3.months,
  timezone: "America/New_York",
  availability_json: {
    "monday" => ["11:00-15:00", "16:00-20:00"],
    "tuesday" => ["11:00-15:00", "16:00-20:00"],
    "wednesday" => ["11:00-15:00"],
    "thursday" => ["11:00-15:00", "16:00-20:00"]
  }
)

puts "✅ Created availability windows for therapists"

# Create Demo Insurance Plans
puts "🏥 Creating demo insurance plans..."

insurances = [
  { name: "Blue Cross Blue Shield", state: "CA", network_status: 1 },
  { name: "Aetna", state: "CA", network_status: 1 },
  { name: "UnitedHealthcare", state: "CA", network_status: 1 },
  { name: "Cigna", state: "CA", network_status: 1 },
  { name: "Kaiser Permanente", state: "CA", network_status: 2 },
  { name: "Blue Cross Blue Shield", state: "NY", network_status: 1 },
  { name: "Aetna", state: "NY", network_status: 1 },
  { name: "Medicaid", state: "CA", network_status: 1 }
]

created_insurances = insurances.map do |ins|
  CredentialedInsurance.create!(
    name: ins[:name],
    state: ins[:state],
    country: "US",
    network_status: ins[:network_status],
    associates_allowed: true
  )
end

puts "✅ Created #{CredentialedInsurance.count} insurance plans"

# Link therapists to insurance plans
puts "🔗 Linking therapists to insurance plans..."

ca_insurances = created_insurances.select { |i| i.state == "CA" }
ny_insurances = created_insurances.select { |i| i.state == "NY" }

# Dr. Sarah accepts most CA insurances
ca_insurances.each do |insurance|
  therapist1.clinician_credentialed_insurances.create!(
    credentialed_insurance: insurance
  )
end

# Dr. Mike accepts some CA insurances
[ca_insurances[0], ca_insurances[1], ca_insurances[4]].each do |insurance|
  therapist2.clinician_credentialed_insurances.create!(
    credentialed_insurance: insurance
  )
end

# Emily accepts CA and NY insurances
(ca_insurances[0..2] + ny_insurances).each do |insurance|
  therapist3.clinician_credentialed_insurances.create!(
    credentialed_insurance: insurance
  )
end

puts "✅ Linked therapists to insurance plans"

# Create Demo Screeners (if they don't exist)
puts "📋 Creating demo screeners..."

unless Screener.exists?(key: 'phq9-teen')
  Screener.create!(
    key: 'phq9-teen',
    title: 'PHQ-9 Modified for Teens',
    version: '1.0',
    items_json: {
      "questions" => [
        {
          "id" => 1,
          "text" => "Little interest or pleasure in doing things",
          "options" => ["Not at all", "Several days", "More than half the days", "Nearly every day"]
        },
        {
          "id" => 2,
          "text" => "Feeling down, depressed, or hopeless",
          "options" => ["Not at all", "Several days", "More than half the days", "Nearly every day"]
        },
        {
          "id" => 3,
          "text" => "Trouble falling or staying asleep, or sleeping too much",
          "options" => ["Not at all", "Several days", "More than half the days", "Nearly every day"]
        }
      ]
    }
  )
end

unless Screener.exists?(key: 'gad7-teen')
  Screener.create!(
    key: 'gad7-teen',
    title: 'GAD-7 for Teens',
    version: '1.0',
    items_json: {
      "questions" => [
        {
          "id" => 1,
          "text" => "Feeling nervous, anxious, or on edge",
          "options" => ["Not at all", "Several days", "More than half the days", "Nearly every day"]
        },
        {
          "id" => 2,
          "text" => "Not being able to stop or control worrying",
          "options" => ["Not at all", "Several days", "More than half the days", "Nearly every day"]
        }
      ]
    }
  )
end

puts "✅ Created screeners"

puts ""
puts "🎉 Seed complete!"
puts ""
puts "Demo Therapists Created:"
puts "------------------------"
Therapist.all.each do |t|
  puts "• #{t.display_name} (#{t.email})"
  puts "  Specialties: #{t.specialties.join(', ')}"
  puts "  Licensed in: #{t.licensed_states.join(', ')}"
  puts "  Capacity: #{t.capacity_filled}/#{t.capacity_total} (#{t.capacity_available} available)"
  puts ""
end

puts "Insurance Plans: #{CredentialedInsurance.count}"
puts "Screeners: #{Screener.count}"
puts ""
puts "✅ Your demo environment is ready!"
puts "🚀 Parents can now complete onboarding and book appointments with therapists."

