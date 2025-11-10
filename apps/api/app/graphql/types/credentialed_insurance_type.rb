module Types
  class CredentialedInsuranceType < Types::BaseObject
    description "An insurance plan that therapists can be credentialed with"

    field :id, ID, null: false
    field :parent_credentialed_insurance_id, ID, null: true
    field :name, String, null: false
    field :country, String, null: false
    field :state, String, null: true
    field :line_of_business, String, null: true
    field :legacy_names, [String], null: true
    field :open_pm_name, String, null: true
    field :network_status, Integer, null: false
    field :associates_allowed, Boolean, null: false
    field :legacy_id, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Hierarchical relationships
    field :parent_credentialed_insurance, Types::CredentialedInsuranceType, null: true
    field :child_credentialed_insurances, [Types::CredentialedInsuranceType], null: false

    # Associations
    field :therapists, [Types::TherapistType], null: false
    field :clinician_credentialed_insurances, [Types::ClinicianCredentialedInsuranceType], null: false

    # Computed fields
    field :in_network, Boolean, null: false
    field :out_of_network, Boolean, null: false
    field :display_name, String, null: false
    field :full_name, String, null: false
    field :root_insurance, Types::CredentialedInsuranceType, null: true

    # Computed field resolvers
    def in_network
      object.in_network?
    end

    def out_of_network
      object.out_of_network?
    end

    def display_name
      object.display_name
    end

    def full_name
      object.full_name
    end

    def root_insurance
      object.root_insurance
    end
  end
end

