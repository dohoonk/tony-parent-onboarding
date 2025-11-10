module Queries
  class Memberships < BaseQuery
    type [Types::MembershipType], null: false
    description "List memberships (user-organization relationships)"

    argument :user_id, ID, required: false, description: "Filter by user ID"
    argument :user_type, String, required: false, description: "Filter by user type (Parent or Student)"
    argument :organization_id, ID, required: false, description: "Filter by organization ID"

    def resolve(user_id: nil, user_type: nil, organization_id: nil)
      parent = context[:current_user]
      
      unless parent
        raise Errors::AuthenticationError.new("Authentication required")
      end

      # Start with base query
      memberships = Membership.all

      # Apply filters
      if user_id.present? && user_type.present?
        memberships = memberships.where(user_id: user_id, user_type: user_type)
      elsif user_id.present?
        # Try to find as both Parent and Student
        user = Parent.find_by(id: user_id) || Student.find_by(id: user_id)
        if user
          memberships = Membership.for_user(user)
        else
          return []
        end
      end

      if organization_id.present?
        memberships = memberships.for_organization(organization_id)
      end

      # Authorization: Parents can only see their own memberships or their students' memberships
      unless parent.has_role?(:staff) || parent.has_role?(:admin)
        # Filter to only show memberships where the current parent or their students are involved
        student_ids = parent.students.pluck(:id)
        memberships = memberships.where(
          '(user_type = ? AND user_id = ?) OR (user_type = ? AND user_id IN (?))',
          'Parent', parent.id, 'Student', student_ids
        )
      end

      memberships.order(created_at: :desc)
    end
  end
end

