module Queries
  class Referrals < BaseQuery
    type [Types::ReferralType], null: false
    description "List referrals, optionally filtered by organization or submitter"

    argument :organization_id, ID, required: false
    argument :submitter_id, ID, required: false
    argument :status, String, required: false, description: "Filter by status: pending, referred, scheduled, enrolled, disenrolled, rejected"

    def resolve(organization_id: nil, submitter_id: nil, status: nil)
      parent = context[:current_user]
      
      unless parent
        raise Errors::AuthenticationError.new("Authentication required")
      end

      # Start with base query
      referrals = Referral.all

      # Apply filters based on authorization
      if parent.has_role?(:staff) || parent.has_role?(:admin)
        # Staff and admin can see all referrals
        referrals = referrals.where(organization_id: organization_id) if organization_id.present?
        referrals = referrals.where(submitter_id: submitter_id) if submitter_id.present?
      else
        # Parents can only see their own referrals
        referrals = referrals.where(submitter_id: parent.id)
      end

      # Apply status filter
      if status.present?
        case status
        when 'referred'
          referrals = referrals.referred
        when 'scheduled'
          referrals = referrals.scheduled
        when 'enrolled'
          referrals = referrals.enrolled
        when 'disenrolled'
          referrals = referrals.disenrolled
        when 'rejected'
          referrals = referrals.rejected
        when 'ready_for_scheduling'
          referrals = referrals.ready_for_scheduling
        when 'pending'
          referrals = referrals.where(referred_at: nil)
        end
      end

      referrals.order(created_at: :desc)
    end
  end
end

