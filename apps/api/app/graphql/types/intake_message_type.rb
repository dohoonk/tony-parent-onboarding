module Types
  class IntakeMessageType < Types::BaseObject
    description "A message in the AI-powered intake conversation"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :role, Types::MessageRoleEnum, null: false
    field :content, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false
  end
end

