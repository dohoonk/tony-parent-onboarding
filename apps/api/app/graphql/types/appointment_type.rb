module Types
  class AppointmentType < Types::BaseObject
    description "A scheduled therapy appointment"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :student_id, ID, null: false
    field :therapist_id, ID, null: false
    field :scheduled_at, GraphQL::Types::ISO8601DateTime, null: false
    field :duration_minutes, Integer, null: false
    field :status, Types::AppointmentStatusEnum, null: false
    field :notes, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false
    field :student, Types::StudentType, null: false
    field :therapist, Types::TherapistType, null: false
  end
end

