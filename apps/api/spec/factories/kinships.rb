FactoryBot.define do
  factory :kinship do
    association :user_0, factory: :parent
    user_0_type { 'Parent' }
    association :user_1, factory: :student
    user_1_type { 'Student' }
    kind { 1 } # 1 = parent-child
    user_0_label { 'Parent' }
    user_1_label { 'Child' }
    guardian_can_be_contacted { false }
    migration_details { {} }

    trait :parent_student do
      association :user_0, factory: :parent
      user_0_type { 'Parent' }
      association :user_1, factory: :student
      user_1_type { 'Student' }
      kind { 1 }
    end
  end
end

