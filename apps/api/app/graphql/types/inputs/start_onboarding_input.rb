module Types
  module Inputs
    class StartOnboardingInput < Types::BaseInputObject
      description "Input for starting a new onboarding session"

      argument :student_id, ID, required: true, description: "ID of the student for onboarding"
    end
  end
end

