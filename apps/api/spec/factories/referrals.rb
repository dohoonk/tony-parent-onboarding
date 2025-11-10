FactoryBot.define do
  factory :referral do
    association :submitter, factory: :parent
    association :organization, :district
    service_kind { 1 } # 1 = individual
    terms_kind { 1 } # 1 = sponsored
    appointment_kind { 1 } # 1 = virtual
    planned_sessions { 12 }
    collect_coverage { true }
    allowed_coverage { ['insurance', 'self_pay'] }
    self_responsibility_required { false }
    care_provider_requirements { [] }
    system_labels { [] }
    tzdb { 'America/Los_Angeles' }
    data { {} }

    trait :with_contract do
      association :contract
    end

    trait :referred do
      referred_at { Time.current }
    end

    trait :scheduled do
      scheduled_at { Time.current }
    end

    trait :enrolled do
      enrolled_at { Time.current }
    end
  end
end

