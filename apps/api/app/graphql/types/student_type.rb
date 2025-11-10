module Types
  class StudentType < Types::BaseObject
    description "A student (child) receiving mental health services"

    field :id, ID, null: false
    field :parent_id, ID, null: false
    field :first_name, String, null: false
    field :last_name, String, null: false
    field :date_of_birth, GraphQL::Types::ISO8601Date, null: false
    field :grade, String, null: true
    field :school, String, null: true
    field :language, String, null: false
    field :age, Integer, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :parent, Types::ParentType, null: false
    field :onboarding_sessions, [Types::OnboardingSessionType], null: false
  end
end

