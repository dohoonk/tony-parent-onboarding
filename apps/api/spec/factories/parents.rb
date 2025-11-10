FactoryBot.define do
  factory :parent do
    sequence(:email) { |n| "parent#{n}@example.com" }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    auth_provider { 'magic_link' }
    role { 'parent' }
  end
end

