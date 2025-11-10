module Mutations
  class UpdateReferralStatus < BaseMutation
    description "Update the status of a referral"

    argument :input, Types::Inputs::UpdateReferralStatusInput, required: true

    field :referral, Types::ReferralType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { referral: nil, errors: ["Authentication required"] }
      end

      # Find the referral
      referral = Referral.find_by(id: input.referral_id)
      unless referral
        return { referral: nil, errors: ["Referral not found"] }
      end

      # Check authorization - parent can only update their own referrals
      unless referral.submitter_id == parent.id || parent.has_role?(:staff) || parent.has_role?(:admin)
        return { referral: nil, errors: ["Not authorized to update this referral"] }
      end

      # Update status based on input
      case input.status
      when 'referred'
        referral.mark_referred!
      when 'ready_for_scheduling'
        referral.mark_ready_for_scheduling!
      when 'scheduled'
        referral.mark_scheduled!
      when 'enrolled'
        referral.mark_enrolled!
      when 'disenrolled'
        referral.mark_disenrolled!(category: input.category)
      when 'rejected'
        referral.mark_rejected!(cause: input.cause)
      else
        return { referral: nil, errors: ["Invalid status: #{input.status}"] }
      end

      # Update notes if provided
      if input.notes.present?
        referral.update!(notes: referral.notes.to_s + "\n#{input.notes}")
      end

      # Log audit trail
      AuditLog.log_access(
        actor: parent,
        action: 'write',
        entity: referral,
        after: referral.attributes
      )

      { referral: referral, errors: [] }
    rescue StandardError => e
      { referral: nil, errors: [e.message] }
    end
  end
end

