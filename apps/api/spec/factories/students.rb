FactoryBot.define do
  factory :student do
    association :parent
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    date_of_birth { Faker::Date.birthday(min_age: 5, max_age: 18) }
    grade { %w[K 1 2 3 4 5 6 7 8 9 10 11 12].sample }
    school { Faker::Educator.secondary_school }
    language { 'en' }
  end
end

