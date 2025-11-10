module Mutations
  class GeneratePresignedUrl < BaseMutation
    description "Generate presigned S3 URL for insurance card upload"

    argument :session_id, ID, required: true
    argument :side, String, required: true, description: "Either 'front' or 'back'"
    argument :content_type, String, required: false, default_value: "image/jpeg"

    field :url, String, null: false
    field :key, String, null: false
    field :errors, [String], null: false

    def resolve(session_id:, side:, content_type:)
      require_authentication!
      
      unless %w[front back].include?(side)
        return { url: nil, key: nil, errors: ["Side must be 'front' or 'back'"] }
      end

      session = current_user.onboarding_sessions.find_by(id: session_id)
      
      unless session
        return { url: nil, key: nil, errors: ["Session not found"] }
      end

      # Generate S3 key
      key = S3Service.generate_key(session_id: session.id, side: side)

      # Generate presigned URL
      s3_service = S3Service.new
      url = s3_service.presigned_upload_url(key: key, content_type: content_type)

      # Log audit trail
      AuditLog.log_access(
        actor: current_user,
        action: 'write',
        entity: session,
        after: { s3_upload_key: key, side: side }
      )

      { url: url, key: key, errors: [] }
    rescue StandardError => e
      Rails.logger.error("Presigned URL generation failed: #{e.message}")
      { url: nil, key: nil, errors: ["Failed to generate upload URL: #{e.message}"] }
    end
  end
end

