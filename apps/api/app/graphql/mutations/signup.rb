module Mutations
  class Signup < BaseMutation
    description "Create a new parent account with email and password"

    argument :email, String, required: true
    argument :password, String, required: true
    argument :first_name, String, required: true
    argument :last_name, String, required: true

    field :parent, Types::ParentType, null: true
    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(email:, password:, first_name:, last_name:)
      # Check if parent already exists
      existing_parent = Parent.find_by(email: email.downcase.strip)
      
      if existing_parent
        return { parent: nil, token: nil, errors: ["Email already registered"] }
      end

      # Create new parent
      parent = Parent.new(
        email: email.downcase.strip,
        password: password,
        first_name: first_name,
        last_name: last_name,
        auth_provider: 'password',
        account_status: 'active'
      )

      if parent.save
        # Generate JWT token
        token = JwtService.encode(parent)
        
        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: parent,
          after: parent.attributes
        )

        { parent: parent, token: token, errors: [] }
      else
        { parent: nil, token: nil, errors: parent.errors.full_messages }
      end
    end
  end
end

