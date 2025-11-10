class InsuranceCard < ApplicationRecord
  # Associations
  belongs_to :onboarding_session

  # Validations
  validates :front_image_url, presence: true, format: { with: URI::regexp(%w[http https]) }
  validates :back_image_url, format: { with: URI::regexp(%w[http https]) }, allow_blank: true

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
end

