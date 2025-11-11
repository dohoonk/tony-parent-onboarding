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
        Rails.logger.info("=" * 80)
        Rails.logger.info("INSURANCE CARD UPLOADED - Starting OCR Extraction")
        Rails.logger.info("Card ID: #{card.id}")
        Rails.logger.info("Front Image URL: #{card.front_image_url}")
        Rails.logger.info("Back Image URL: #{card.back_image_url || 'N/A'}")
        Rails.logger.info("=" * 80)
        
        # Perform OCR extraction immediately
        begin
          Rails.logger.info(">>> Calling InsuranceOcrService.extract...")
          extraction_result = InsuranceOcrService.extract(
            front_image_url: card.front_image_url,
            back_image_url: card.back_image_url
          )
          
          Rails.logger.info(">>> OCR extraction completed successfully!")
          Rails.logger.info(">>> Extracted fields: #{extraction_result[:extracted_data].keys.join(', ')}")
          Rails.logger.info(">>> Full extracted data: #{extraction_result[:extracted_data].inspect}")
          
          # Save OCR results
          card.update!(
            ocr_json: extraction_result[:extracted_data],
            confidence_json: extraction_result[:confidence_scores]
          )
          
          Rails.logger.info("=" * 80)
          Rails.logger.info("OCR EXTRACTION SUCCESSFUL")
          Rails.logger.info("Card ID: #{card.id}")
          Rails.logger.info("Saved OCR data to database")
          Rails.logger.info("=" * 80)
        rescue StandardError => e
          Rails.logger.error("=" * 80)
          Rails.logger.error("OCR EXTRACTION FAILED")
          Rails.logger.error("Card ID: #{card.id}")
          Rails.logger.error("Error: #{e.class.name} - #{e.message}")
          Rails.logger.error("Backtrace:")
          Rails.logger.error(e.backtrace.join("\n"))
          Rails.logger.error("=" * 80)
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

