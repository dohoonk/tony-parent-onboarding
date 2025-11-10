module Types
  class OnboardingStatusEnum < Types::BaseEnum
    description "Status of an onboarding session"

    value "DRAFT", "Initial draft state", value: "draft"
    value "ACTIVE", "Actively in progress", value: "active"
    value "COMPLETED", "Successfully completed", value: "completed"
    value "ABANDONED", "Abandoned by user", value: "abandoned"
  end
end

