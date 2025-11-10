module Types
  class MutationType < Types::BaseObject
    description "The mutation root of this schema"

    field :start_onboarding, mutation: Mutations::StartOnboarding
    field :ai_intake_message, mutation: Mutations::AiIntakeMessage
    field :stream_ai_intake_message, mutation: Mutations::StreamAiIntakeMessage
    field :extract_intake_summary, mutation: Mutations::ExtractIntakeSummary
    field :submit_screener, mutation: Mutations::SubmitScreener
    field :generate_presigned_url, mutation: Mutations::GeneratePresignedUrl
    field :upload_insurance_card, mutation: Mutations::UploadInsuranceCard
    field :confirm_insurance, mutation: Mutations::ConfirmInsurance
    field :book_appointment, mutation: Mutations::BookAppointment
  end
end

