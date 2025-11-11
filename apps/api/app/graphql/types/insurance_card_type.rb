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

    # Transform OCR data into the format expected by frontend
    # Frontend expects: { payer_name: { value: "...", confidence: "high" }, ... }
    # Backend stores: { payer_name: "...", ... } and { payer_name: "high", ... }
    field :extracted_data, GraphQL::Types::JSON, null: true do
      description "OCR extracted data in frontend-friendly format with nested value/confidence structure"
    end

    def extracted_data
      return nil unless object.ocr_json.present? && object.confidence_json.present?

      ocr_data = object.ocr_json || {}
      confidence_data = object.confidence_json || {}

      # Transform flat structure to nested structure
      result = {}
      ocr_data.each do |key, value|
        confidence = confidence_data[key.to_s] || confidence_data[key.to_sym] || 'low'
        result[key.to_s] = {
          'value' => value.to_s,
          'confidence' => confidence.to_s
        }
      end

      result
    end
  end
end

