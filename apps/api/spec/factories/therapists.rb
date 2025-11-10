FactoryBot.define do
  factory :therapist do
    sequence(:email) { |n| "therapist#{n}@example.com" }
    sequence(:healthie_id) { |n| "10000#{n}" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    preferred_language { 'en' }
    standardized_gender { 'Female' }
    employment_type { 'W2 Hourly' }
    clinical_role { 'Therapist' }
    primary_state { 'CA' }
    capacity_total { 20 }
    capacity_filled { 0 }
    capacity_available { 20 }
    capacity_total_daybreak { 10 }
    capacity_filled_daybreak { 0 }
    capacity_available_daybreak { 10 }
    capacity_total_kaiser { 10 }
    capacity_filled_kaiser { 0 }
    capacity_available_kaiser { 10 }
    active { true }
    specialties { ['Anxiety', 'Depression'] }
    modalities { ['CBT', 'DBT'] }
    care_languages { ['en'] }
    licensed_states { ['CA'] }
    licenses { ['LCSW'] }
    profile_data { {} }

    trait :with_supervisor do
      association :supervisor, factory: :therapist
    end

    trait :inactive do
      active { false }
    end

    trait :with_capacity do
      capacity_total { 20 }
      capacity_filled { 5 }
      capacity_available { 15 }
    end

    trait :no_capacity do
      capacity_total { 20 }
      capacity_filled { 20 }
      capacity_available { 0 }
    end
  end
end

