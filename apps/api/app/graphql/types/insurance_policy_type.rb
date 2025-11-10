module Types
  class InsurancePolicyType < Types::BaseObject
    description "Confirmed insurance policy information"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :payer_name, String, null: false
    # Note: member_id and group_number are encrypted, not exposed via GraphQL for security
    field :plan_type, String, null: true
    field :subscriber_name, String, null: true
    field :verified_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false
  end
end

