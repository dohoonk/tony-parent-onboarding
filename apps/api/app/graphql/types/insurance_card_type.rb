module Types
  class InsuranceCardType < Types::BaseObject
    description "Uploaded insurance card with OCR data"

    field :id, ID, null: false
    field :session_id, ID, null: false
    field :front_image_url, String, null: false
    field :back_image_url, String, null: true
    field :ocr_data, GraphQL::Types::JSON, null: true
    field :confidence_scores, GraphQL::Types::JSON, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false

    field :onboarding_session, Types::OnboardingSessionType, null: false
  end
end

