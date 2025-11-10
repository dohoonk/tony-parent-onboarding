module Types
  module Inputs
    class CreateReferralInput < Types::BaseInputObject
      description "Input for creating a new referral"

      argument :organization_id, ID, required: true
      argument :student_id, ID, required: true
      argument :service_kind, Integer, required: true
      argument :concerns, String, required: false
      argument :contract_id, ID, required: false
      argument :terms_kind, Integer, required: true
      argument :appointment_kind, Integer, required: true
      argument :planned_sessions, Integer, required: false
      argument :collect_coverage, Boolean, required: false, default_value: false
      argument :allowed_coverage, [String], required: false, default_value: []
      argument :collection_rule, Integer, required: false
      argument :self_responsibility_required, Boolean, required: false, default_value: false
      argument :care_provider_requirements, [String], required: false, default_value: []
      argument :tzdb, String, required: false
      argument :data, GraphQL::Types::JSON, required: false
    end
  end
end

