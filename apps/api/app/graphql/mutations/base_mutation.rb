module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    argument_class Types::BaseArgument
    field_class Types::BaseField
    object_class Types::BaseObject

    # Helper method to get current user from context
    def current_user
      context[:current_user]
    end

    # Helper method to check if user is authenticated
    def authenticated?
      current_user.present?
    end

    # Helper method to require authentication
    def require_authentication!
      raise GraphQL::ExecutionError, "Authentication required" unless authenticated?
    end

    # Helper method for authorization checks
    def authorize_parent_access!(resource)
      return if resource.nil?
      
      parent_id = case resource
                  when Parent
                    resource.id
                  when Student
                    resource.parent_id
                  when OnboardingSession
                    resource.parent_id
                  else
                    # Try to get parent_id from association
                    resource.try(:parent_id) || resource.try(:onboarding_session)&.parent_id
                  end

      unless current_user&.id == parent_id
        raise GraphQL::ExecutionError, "Unauthorized access"
      end
    end
  end
end

