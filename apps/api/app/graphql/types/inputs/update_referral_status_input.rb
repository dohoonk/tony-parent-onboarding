module Types
  module Inputs
    class UpdateReferralStatusInput < BaseInputObject
      description "Input for updating referral status"

      argument :referral_id, ID, required: true
      argument :status, String, required: true, description: "One of: referred, ready_for_scheduling, scheduled, enrolled, disenrolled, rejected"
      argument :cause, String, required: false, description: "Optional cause/reason for status change (e.g., rejection cause)"
      argument :category, String, required: false, description: "Optional category for disenrollment"
      argument :notes, String, required: false, description: "Additional notes"
    end
  end
end

