module Types
  class ParentType < Types::BaseObject
    description "A parent or guardian user"

    field :id, ID, null: false
    field :email, String, null: false
    field :phone, String, null: true
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :auth_provider, String, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :students, [Types::StudentType], null: false
    field :onboarding_sessions, [Types::OnboardingSessionType], null: false
  end
end

