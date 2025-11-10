module Types
  module Inputs
    class ConfirmInsuranceInput < Types::BaseInputObject
      description "Input for confirming insurance policy details"

      argument :session_id, ID, required: true, description: "ID of the onboarding session"
      argument :payer_name, String, required: true, description: "Insurance company name"
      argument :member_id, String, required: true, description: "Member/policy ID"
      argument :group_number, String, required: false, description: "Group number"
      argument :plan_type, String, required: false, description: "Plan type"
      argument :subscriber_name, String, required: false, description: "Subscriber name"
    end
  end
end

