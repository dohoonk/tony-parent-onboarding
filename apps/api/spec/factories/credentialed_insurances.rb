FactoryBot.define do
  factory :credentialed_insurance do
    name { 'Aetna' }
    country { 'US' }
    state { 'CA' }
    network_status { 1 }
    associates_allowed { false }
    legacy_names { [] }

    trait :in_network do
      network_status { 1 }
    end

    trait :out_of_network do
      network_status { 0 }
    end

    trait :with_parent do
      association :parent_credentialed_insurance, factory: :credentialed_insurance
    end
  end
end

