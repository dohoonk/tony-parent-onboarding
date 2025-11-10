module Types
  class ClinicianCredentialedInsuranceType < Types::BaseObject
    description "Join table linking therapists to credentialed insurances"

    field :id, ID, null: false
    field :care_provider_profile_id, ID, null: false
    field :credentialed_insurance_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :therapist, Types::TherapistType, null: false
    field :credentialed_insurance, Types::CredentialedInsuranceType, null: false
  end
end

