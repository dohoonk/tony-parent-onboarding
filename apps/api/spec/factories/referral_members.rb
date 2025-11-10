FactoryBot.define do
  factory :referral_member do
    association :referral
    role { 0 } # 0 = student, 1 = parent
    
    trait :student do
      role { 0 }
      association :user, factory: :student
      user_type { 'Student' }
    end

    trait :parent do
      role { 1 }
      association :user, factory: :parent
      user_type { 'Parent' }
    end

    data { {} }
  end
end

