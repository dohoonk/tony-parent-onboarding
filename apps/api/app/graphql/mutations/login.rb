module Mutations
  class Login < BaseMutation
    description "Authenticate a parent with email and password"

    argument :email, String, required: true
    argument :password, String, required: true

    field :parent, Types::ParentType, null: true
    field :token, String, null: true
    field :errors, [String], null: false

    def resolve(email:, password:)
      # Find parent by email
      parent = Parent.find_by(email: email.downcase.strip)
      
      unless parent
        return { parent: nil, token: nil, errors: ["Invalid email or password"] }
      end

      # Check if parent has password authentication
      unless parent.auth_provider == 'password' && parent.password_digest.present?
        return { parent: nil, token: nil, errors: ["Account not set up for password login"] }
      end

      # Authenticate with password
      unless parent.authenticate(password)
        return { parent: nil, token: nil, errors: ["Invalid email or password"] }
      end

      # Generate JWT token
      token = JwtService.encode(parent_id: parent.id)
      
      # Log audit trail
      AuditLog.log_access(
        actor: parent,
        action: 'read',
        entity: parent
      )

      { parent: parent, token: token, errors: [] }
    end
  end
end

