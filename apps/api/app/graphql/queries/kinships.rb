module Queries
  class Kinships < BaseQuery
    type [Types::KinshipType], null: false
    description "List kinships (relationships) for a user"

    argument :user_id, ID, required: false, description: "Filter by user ID"
    argument :user_type, String, required: false, description: "Filter by user type (Parent or Student)"
    argument :kind, Integer, required: false, description: "Filter by relationship kind (1 = parent-child)"

    def resolve(user_id: nil, user_type: nil, kind: nil)
      parent = context[:current_user]
      
      unless parent
        raise Errors::AuthenticationError.new("Authentication required")
      end

      # Start with base query
      kinships = Kinship.all

      # Apply filters
      if user_id.present? && user_type.present?
        # Find the user
        user = case user_type
               when 'Parent'
                 Parent.find_by(id: user_id)
               when 'Student'
                 Student.find_by(id: user_id)
               else
                 nil
               end
        
        if user
          kinships = Kinship.for_user(user)
        else
          return []
        end
      elsif user_id.present?
        # Try to find as both Parent and Student
        user = Parent.find_by(id: user_id) || Student.find_by(id: user_id)
        if user
          kinships = Kinship.for_user(user)
        else
          return []
        end
      end

      # Apply kind filter
      if kind.present?
        kinships = kinships.where(kind: kind)
      end

      # Authorization: Parents can only see their own kinships
      unless parent.has_role?(:staff) || parent.has_role?(:admin)
        # Filter to only show kinships where the current parent is involved
        kinships = kinships.where('(user_0_type = ? AND user_0_id = ?) OR (user_1_type = ? AND user_1_id = ?)', 'Parent', parent.id, 'Parent', parent.id)
      end

      kinships.order(created_at: :desc)
    end
  end
end

