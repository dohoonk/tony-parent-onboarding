class S3Service
  BUCKET_NAME = ENV.fetch('AWS_S3_BUCKET', 'daybreak-insurance-cards')
  REGION = ENV.fetch('AWS_REGION', 'us-east-1')
  EXPIRATION = 1.hour

  def initialize
    @s3_client = Aws::S3::Client.new(
      region: REGION,
      access_key_id: access_key_id,
      secret_access_key: secret_access_key
    )
  end

  # Generate presigned URL for uploading
  # @param key [String] S3 object key
  # @param content_type [String] MIME type of the file
  # @return [String] Presigned URL
  def presigned_upload_url(key:, content_type: 'image/jpeg')
    signer = Aws::S3::Presigner.new(client: @s3_client)
    
    signer.presigned_url(
      :put_object,
      bucket: BUCKET_NAME,
      key: key,
      content_type: content_type,
      expires_in: EXPIRATION.to_i
    )
  end

  # Generate presigned URL for reading
  # @param key [String] S3 object key
  # @param expiration [Integer] Expiration time in seconds
  # @return [String] Presigned URL
  def presigned_read_url(key:, expiration: 1.hour.to_i)
    signer = Aws::S3::Presigner.new(client: @s3_client)
    
    signer.presigned_url(
      :get_object,
      bucket: BUCKET_NAME,
      key: key,
      expires_in: expiration
    )
  end

  # Upload file directly to S3
  # @param key [String] S3 object key
  # @param file_path [String] Path to local file
  # @param content_type [String] MIME type
  # @return [Boolean] Success status
  def upload_file(key:, file_path:, content_type: 'image/jpeg')
    @s3_client.put_object(
      bucket: BUCKET_NAME,
      key: key,
      body: File.read(file_path),
      content_type: content_type
    )
    true
  rescue Aws::S3::Errors::ServiceError => e
    Rails.logger.error("S3 upload failed: #{e.message}")
    false
  end

  # Generate unique key for insurance card image
  # @param session_id [Integer] Onboarding session ID
  # @param side [String] 'front' or 'back'
  # @return [String] S3 key
  def self.generate_key(session_id:, side:)
    timestamp = Time.now.to_i
    "insurance-cards/#{session_id}/#{side}-#{timestamp}.jpg"
  end

  private

  def access_key_id
    Rails.application.credentials.aws_access_key_id || ENV['AWS_ACCESS_KEY_ID']
  end

  def secret_access_key
    Rails.application.credentials.aws_secret_access_key || ENV['AWS_SECRET_ACCESS_KEY']
  end
end

