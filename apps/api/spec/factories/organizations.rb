FactoryBot.define do
  factory :organization do
    sequence(:slug) { |n| "test-org-#{n}" }
    name { Faker::Company.name }
    kind { 'district' }
    tzdb { 'America/Los_Angeles' }
    market_id { SecureRandom.uuid }
    config { {} }

    trait :district do
      kind { 'district' }
      parent_organization_id { nil }
    end

    trait :school do
      kind { 'school' }
      association :parent_organization, factory: :organization, strategy: :build
    end

    trait :enabled do
      enabled_at { Time.current }
    end

    trait :disabled do
      enabled_at { nil }
    end

    trait :with_schools do
      after(:create) do |district|
        create_list(:organization, 2, :school, parent_organization: district)
      end
    end
  end
end

