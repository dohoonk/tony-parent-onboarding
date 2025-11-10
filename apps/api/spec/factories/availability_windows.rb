FactoryBot.define do
  factory :availability_window do
    association :owner, factory: :therapist
    start_date { Date.current }
    end_date { 1.year.from_now.to_date }
    rrule { 'FREQ=WEEKLY;BYDAY=MO,WE,FR' }
    availability_json { nil }
    timezone { 'America/Los_Angeles' }

    trait :with_json_format do
      rrule { nil }
      availability_json do
        {
          'days' => [
            { 'day' => 'Monday', 'time_blocks' => [
              { 'start' => '09:00:00', 'duration' => 60 },
              { 'start' => '10:00:00', 'duration' => 60 }
            ]},
            { 'day' => 'Wednesday', 'time_blocks' => [
              { 'start' => '14:00:00', 'duration' => 60 }
            ]}
          ]
        }
      end
    end

    trait :with_rrule_format do
      rrule { 'FREQ=WEEKLY;BYDAY=MO,WE,FR' }
      availability_json { nil }
    end

    trait :for_therapist do
      association :owner, factory: :therapist
    end

    trait :for_parent do
      association :owner, factory: :parent
    end
  end
end

