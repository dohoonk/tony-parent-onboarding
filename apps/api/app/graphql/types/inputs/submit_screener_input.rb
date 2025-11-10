module Types
  module Inputs
    class SubmitScreenerInput < Types::BaseInputObject
      description "Input for submitting a clinical screener response"

      argument :session_id, ID, required: true, description: "ID of the onboarding session"
      argument :screener_key, String, required: true, description: "Screener key (e.g., 'phq9', 'gad7')"
      argument :answers, GraphQL::Types::JSON, required: true, description: "Screener answers as JSON"
    end
  end
end

