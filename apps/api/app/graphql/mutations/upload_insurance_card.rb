module Mutations
  class UploadInsuranceCard < BaseMutation
    description "Upload an insurance card for OCR processing"

    argument :input, Types::Inputs::UploadInsuranceCardInput, required: true

    field :insurance_card, Types::InsuranceCardType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { insurance_card: nil, errors: ["Authentication required"] }
      end

      # Handle temporary session IDs (from frontend before real session is created)
      # If session_id starts with "temp-session-", create or find an active session
      if input.session_id&.start_with?('temp-session-')
        # Find or create an active session for this parent
        # Use the first student, or create a temporary one if none exists
        student = parent.students.first
        
        unless student
          # Create a temporary student for testing
          student = parent.students.create!(
            first_name: 'Temporary',
            last_name: 'Student',
            date_of_birth: 10.years.ago,
            language: 'en'
          )
        end
        
        # Find existing active/draft session, or create a new one
        session = parent.onboarding_sessions.in_progress.where(student: student).first
        
        unless session
          # Create new session (validation ensures only one active session per parent+student)
          session = parent.onboarding_sessions.create!(
            student: student,
            status: 'active',
            current_step: 5 # Insurance step
          )
        end
      else
        # Look up real session by ID
        session = parent.onboarding_sessions.find_by(id: input.session_id)
        
        unless session
          return { insurance_card: nil, errors: ["Session not found"] }
        end
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
        rescue InsuranceOcrService::ServiceError => e
          Rails.logger.warn("=" * 80)
          Rails.logger.warn("OCR EXTRACTION SKIPPED")
          Rails.logger.warn("Card ID: #{card.id}")
          Rails.logger.warn("Reason: #{e.message}")
          Rails.logger.warn("=" * 80)
          # Don't fail the upload if OCR is skipped - user can manually enter
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

