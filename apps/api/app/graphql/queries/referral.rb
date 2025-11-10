module Queries
  class Referral < BaseQuery
    type Types::ReferralType, null: true
    description "Get a specific referral by ID"

    argument :id, ID, required: true

    def resolve(id:)
      parent = context[:current_user]
      
      unless parent
        raise Errors::AuthenticationError.new("Authentication required")
      end

      referral = Referral.find_by(id: id)
      return nil unless referral

      # Check authorization
      unless referral.submitter_id == parent.id || parent.has_role?(:staff) || parent.has_role?(:admin)
        raise Errors::AuthorizationError.new("Not authorized to view this referral")
      end

      referral
    end
  end
end

