FactoryBot.define do
  factory :contract do
    effective_date { Date.current }
    end_date { 1.year.from_now.to_date }
    services { ['family_therapy', 'individual_therapy'] }
    terms { [
      {
        'kind' => 'sponsored',
        'services' => ['family_therapy', 'individual_therapy'],
        'initial_cap' => -1,
        'cap_per_patient' => 12
      }
    ] }
    contract_url { 'https://example.com/contract.pdf' }

    trait :active do
      effective_date { 1.month.ago.to_date }
      end_date { 1.year.from_now.to_date }
    end

    trait :expired do
      effective_date { 2.years.ago.to_date }
      end_date { 1.year.ago.to_date }
    end

    trait :upcoming do
      effective_date { 1.month.from_now.to_date }
      end_date { 1.year.from_now.to_date }
    end

    trait :no_end_date do
      end_date { nil }
    end
  end
end

