module Types
  module Inputs
    class AiIntakeMessageInput < Types::BaseInputObject
      description "Input for sending a message in the AI intake conversation"

      argument :session_id, ID, required: true, description: "ID of the onboarding session"
      argument :message, String, required: true, description: "User's message content"
    end
  end
end

