module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request
  end

  private

  def authenticate_request
    @current_user = authenticate_from_token
  end

  def authenticate_from_token
    token = extract_token_from_header || extract_token_from_params
    return nil unless token

    begin
      secret_key = Rails.application.credentials.secret_key_base || 
                   ENV['SECRET_KEY_BASE'] || 
                   (Rails.env.development? ? 'development-secret-key-base-for-jwt-tokens-minimum-32-characters-long' : nil)
      
      unless secret_key
        Rails.logger.error("❌ No secret key available for JWT verification")
        return nil
      end
      
      decoded = JWT.decode(token, secret_key, true, algorithm: 'HS256')
      payload = decoded.first
      
      parent_id = payload['parent_id']
      return nil unless parent_id

      parent = Parent.find_by(id: parent_id)
      
      if parent
        Rails.logger.info("✅ Authentication successful for parent: #{parent.id} (#{parent.email})")
        # Log successful authentication (using 'read' action since 'authenticate' is not in allowed list)
        # Authentication is essentially reading/verifying the parent's identity
        begin
          AuditLog.log_access(
            actor: parent,
            action: 'read',
            entity: parent
          )
        rescue StandardError => e
          # Don't fail authentication if audit logging fails
          Rails.logger.warn("Failed to log authentication to audit log: #{e.message}")
        end
      else
        Rails.logger.warn("⚠️  Parent not found for ID: #{parent_id}")
      end

      parent
    rescue JWT::DecodeError => e
      Rails.logger.warn("❌ JWT decode error: #{e.message}")
      nil
    rescue JWT::ExpiredSignature => e
      Rails.logger.warn("❌ JWT expired: #{e.message}")
      nil
    rescue StandardError => e
      Rails.logger.error("❌ Authentication error: #{e.class.name} - #{e.message}")
      nil
    end
  end

  def extract_token_from_header
    auth_header = request.headers['Authorization']
    
    if Rails.env.development?
      Rails.logger.debug("Authorization header: #{auth_header ? auth_header[0..20] + '...' : 'MISSING'}")
    end
    
    return nil unless auth_header

    # Expected format: "Bearer <token>"
    parts = auth_header.split(' ')
    return nil unless parts.length == 2 && parts[0] == 'Bearer'

    parts[1]
  end

  def extract_token_from_params
    token_param = params[:token] || params[:auth_token] || params[:access_token]

    if Rails.env.development?
      Rails.logger.debug("Token param: #{token_param ? token_param[0..20] + '...' : 'MISSING'}")
    end

    token_param
  end

  def current_user
    @current_user
  end

  def require_authentication!
    unless current_user
      render json: { errors: ['Authentication required'] }, status: :unauthorized
    end
  end
end

