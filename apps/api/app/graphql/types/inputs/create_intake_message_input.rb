module Types
  module Inputs
    class CreateIntakeMessageInput < Types::BaseInputObject
      description "Input for creating a new intake message"

      argument :session_id, ID, required: true, description: "ID of the onboarding session"
      argument :content, String, required: true, description: "Content of the user's message"
    end
  end
end


