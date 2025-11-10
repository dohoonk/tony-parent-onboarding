FactoryBot.define do
  factory :clinician_credentialed_insurance do
    association :therapist
    association :credentialed_insurance
    
    # Set the foreign key manually after association
    after(:build) do |clinician_cred_insurance|
      clinician_cred_insurance.care_provider_profile_id = clinician_cred_insurance.therapist.id
    end
  end
end

