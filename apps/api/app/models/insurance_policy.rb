class InsurancePolicy < ApplicationRecord
  # Associations
  belongs_to :onboarding_session

  # Encryptions (PHI/PII)
  encrypts :member_id, deterministic: true  # Deterministic for search/lookup
  encrypts :group_number                     # Non-deterministic for max security

  # Validations
  validates :payer_name, presence: true
  validates :member_id, presence: true
  validates :onboarding_session_id, uniqueness: true

  # Callbacks
  before_validation :normalize_fields

  private

  def normalize_fields
    self.member_id = member_id&.strip&.upcase
    self.group_number = group_number&.strip&.upcase
    self.payer_name = payer_name&.strip
  end
end

