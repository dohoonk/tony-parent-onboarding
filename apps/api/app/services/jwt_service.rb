class JwtService
  SECRET_KEY = Rails.application.credentials.secret_key_base

  # Encode a JWT token
  # @param parent [Parent] the parent user
  # @param expires_in [Integer] token expiration time in seconds (default: 24 hours)
  # @return [String] JWT token
  def self.encode(parent, expires_in: 24.hours.to_i)
    payload = {
      parent_id: parent.id,
      email: parent.email,
      exp: Time.now.to_i + expires_in,
      iat: Time.now.to_i
    }

    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  # Decode a JWT token
  # @param token [String] the JWT token
  # @return [Hash, nil] decoded payload or nil if invalid
  def self.decode(token)
    decoded = JWT.decode(token, SECRET_KEY, true, algorithm: 'HS256')
    decoded.first
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    Rails.logger.warn("JWT decode failed: #{e.message}")
    nil
  end

  # Verify and return parent from token
  # @param token [String] the JWT token
  # @return [Parent, nil] the parent user or nil
  def self.verify_and_get_parent(token)
    payload = decode(token)
    return nil unless payload

    Parent.find_by(id: payload['parent_id'])
  end

  # Generate a magic link token (shorter expiration)
  # @param parent [Parent] the parent user
  # @return [String] JWT token valid for 15 minutes
  def self.encode_magic_link(parent)
    encode(parent, expires_in: 15.minutes.to_i)
  end
end

