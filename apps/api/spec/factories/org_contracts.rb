FactoryBot.define do
  factory :org_contract do
    association :organization
    association :contract
  end
end

