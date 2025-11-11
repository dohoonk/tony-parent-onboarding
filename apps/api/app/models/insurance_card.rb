class InsuranceCard < ApplicationRecord
  # Associations
  belongs_to :onboarding_session

  DATA_URL_REGEX = %r{\Adata:image/[a-zA-Z0-9.+-]+;base64,}.freeze
  HTTP_URL_REGEX = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  # Validations
  validates :front_image_url, presence: true
  validate :front_image_url_must_be_valid
  validate :back_image_url_must_be_valid

  # Accessors
  def ocr_data
    ocr_json || {}
  end

  def ocr_data=(value)
    self.ocr_json = value
  end

  def confidence_scores
    confidence_json || {}
  end

  def confidence_scores=(value)
    self.confidence_json = value
  end

  # Instance methods
  def extract_policy_info
    # Returns suggested policy info from OCR data
    {
      payer_name: ocr_data.dig('insurance_company', 'text'),
      member_id: ocr_data.dig('member_id', 'text'),
      group_number: ocr_data.dig('group_number', 'text'),
      subscriber_name: ocr_data.dig('subscriber_name', 'text')
    }
  end

  private

  def front_image_url_must_be_valid
    return if valid_image_reference?(front_image_url)

    errors.add(:front_image_url, 'must be an HTTP(S) URL or base64 data URL (data:image/...)')
  end

  def back_image_url_must_be_valid
    return if back_image_url.blank? || valid_image_reference?(back_image_url)

    errors.add(:back_image_url, 'must be an HTTP(S) URL or base64 data URL (data:image/...)')
  end

  def valid_image_reference?(value)
    value.present? && (value.match?(DATA_URL_REGEX) || value.match?(HTTP_URL_REGEX))
  end
end

