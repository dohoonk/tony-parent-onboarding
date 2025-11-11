module Mutations
  class UploadInsuranceCard < BaseMutation
    description "Upload an insurance card for OCR processing"

    argument :input, Types::Inputs::UploadInsuranceCardInput, required: true

    field :insurance_card, Types::InsuranceCardType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { insurance_card: nil, errors: ["Authentication required"] }
      end

      session = parent.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { insurance_card: nil, errors: ["Session not found"] }
      end

      # Create insurance card record
      card = InsuranceCard.new(
        onboarding_session: session,
        front_image_url: input.front_image_url,
        back_image_url: input.back_image_url
      )

      if card.save
        # Perform OCR extraction immediately
        begin
          extraction_result = InsuranceOcrService.extract(
            front_image_url: card.front_image_url,
            back_image_url: card.back_image_url
          )
          
          # Save OCR results
          card.update!(
            ocr_json: extraction_result[:extracted_data],
            confidence_json: extraction_result[:confidence_scores]
          )
          
          Rails.logger.info("OCR extraction successful for card #{card.id}")
          Rails.logger.debug("Extracted data: #{extraction_result[:extracted_data].inspect}")
        rescue StandardError => e
          Rails.logger.error("OCR extraction failed for card #{card.id}: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          # Don't fail the upload if OCR fails - user can manually enter
        end

        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: card,
          after: card.attributes
        )

        { insurance_card: card, errors: [] }
      else
        { insurance_card: nil, errors: card.errors.full_messages }
      end
    end
  end
end

