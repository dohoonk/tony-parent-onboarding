module Types
  class OnboardingSessionType < Types::BaseObject
    description "An onboarding session tracking parent progress"

    field :id, ID, null: false
    field :parent_id, ID, null: false
    field :student_id, ID, null: false
    field :status, Types::OnboardingStatusEnum, null: false
    field :current_step, Integer, null: false
    field :eta_seconds, Integer, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    field :parent, Types::ParentType, null: false
    field :student, Types::StudentType, null: false
    field :intake_messages, [Types::IntakeMessageType], null: false
    field :intake_summary, Types::IntakeSummaryType, null: true
    field :screener_responses, [Types::ScreenerResponseType], null: false
    field :insurance_cards, [Types::InsuranceCardType], null: false
    field :insurance_policy, Types::InsurancePolicyType, null: true
    field :cost_estimate, Types::CostEstimateType, null: true
    field :appointments, [Types::AppointmentType], null: false
  end
end

