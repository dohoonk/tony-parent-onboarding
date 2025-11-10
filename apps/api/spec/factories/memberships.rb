FactoryBot.define do
  factory :membership do
    association :user, factory: :parent
    user_type { 'Parent' }
    association :organization
    census_person_id { nil }
    profile_data { {} }
    migration_details { {} }

    trait :parent do
      association :user, factory: :parent
      user_type { 'Parent' }
    end

    trait :student do
      association :user, factory: :student
      user_type { 'Student' }
    end
  end
end

