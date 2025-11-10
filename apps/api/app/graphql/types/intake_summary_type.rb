module Types
  class IntakeSummaryType < Types::BaseObject
    description "AI-generated summary of the intake conversation"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :concerns, [String], null: false
    field :goals, [String], null: false
    field :risk_flags, [String], null: false
    field :summary_text, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false
  end
end

