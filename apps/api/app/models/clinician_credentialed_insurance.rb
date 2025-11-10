class ClinicianCredentialedInsurance < ApplicationRecord
  self.table_name = 'clinician_credentialed_insurances'

  # Associations
  belongs_to :therapist, foreign_key: 'care_provider_profile_id'
  belongs_to :credentialed_insurance

  # Validations
  validates :care_provider_profile_id, presence: true
  validates :credentialed_insurance_id, presence: true
  validates :care_provider_profile_id, uniqueness: { 
    scope: :credentialed_insurance_id, 
    message: 'already credentialed for this insurance' 
  }

  # Scopes
  scope :for_therapist, ->(therapist_id) { where(care_provider_profile_id: therapist_id) }
  scope :for_insurance, ->(insurance_id) { where(credentialed_insurance_id: insurance_id) }
  scope :in_network, -> { joins(:credentialed_insurance).where(credentialed_insurances: { network_status: 1 }) }
end

