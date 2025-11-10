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
        # TODO: Enqueue OCR job
        # OcrJob.perform_later(card.id)

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

