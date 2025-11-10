module Types
  class ScreenerResponseType < Types::BaseObject
    description "A student's response to a clinical screener"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :screener_id, ID, null: false
    field :answers, GraphQL::Types::JSON, null: false
    field :score, Integer, null: true
    field :interpretation_text, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false
    field :screener, Types::ScreenerType, null: false
  end
end

