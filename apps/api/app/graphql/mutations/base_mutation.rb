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
      raise Errors::AuthenticationError.new unless authenticated?
    end

    # Helper method for role-based authorization
    def authorize!(permission)
      require_authentication!
      
      unless current_user.can?(permission)
        raise Errors::AuthorizationError.new(
          message: "Insufficient permissions: #{permission} required"
        )
      end
    end

    # Helper method for resource-based authorization
    def authorize_access!(resource)
      require_authentication!
      
      return if resource.nil?
      
      unless current_user.can_access?(resource)
        raise Errors::AuthorizationError.new(
          message: "Unauthorized access to #{resource.class.name}"
        )
      end
    end

    # Legacy helper - maintained for backward compatibility
    def authorize_parent_access!(resource)
      authorize_access!(resource)
    end

    # Helper to check if current user has a specific role
    def has_role?(role_name)
      current_user&.has_role?(role_name) || false
    end
  end
end

