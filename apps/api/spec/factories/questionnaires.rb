FactoryBot.define do
  factory :questionnaire do
    association :subject, factory: :student
    association :respondent, factory: :parent
    questionnaire_type { 3 } # custom_intake
    score { 0 }
    language_of_completion { 'eng' }
    question_answers { { 'question_1_answer' => 'yes', 'question_2_answer' => 'no' } }
    started_at { 1.hour.ago }
    completed_at { Time.current }
    census_person_id { nil }

    trait :phq9 do
      questionnaire_type { 1 }
      question_answers { { 'question_1_answer' => 0, 'question_2_answer' => 1 } }
      score { 5 }
    end

    trait :gad7 do
      questionnaire_type { 2 }
      question_answers { { 'question_1_answer' => 0, 'question_2_answer' => 1 } }
      score { 3 }
    end

    trait :in_progress do
      completed_at { nil }
    end

    trait :completed do
      completed_at { Time.current }
    end
  end
end

