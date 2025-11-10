module Types
  class CostEstimateType < Types::BaseObject
    description "Estimated therapy cost range"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :min_cost_cents, Integer, null: false
    field :max_cost_cents, Integer, null: false
    field :min_cost_dollars, Float, null: false
    field :max_cost_dollars, Float, null: false
    field :range_display, String, null: false
    field :basis, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false

    def min_cost_dollars
      object.min_cost_cents / 100.0
    end

    def max_cost_dollars
      object.max_cost_cents / 100.0
    end
  end
end

