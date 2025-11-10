FactoryBot.define do
  factory :onboarding_session do
    association :parent
    association :student
    status { 'active' }
    current_step { 1 }
    eta_seconds { 300 }
  end
end

