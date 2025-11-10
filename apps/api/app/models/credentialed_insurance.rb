class CredentialedInsurance < ApplicationRecord
  # Self-referential associations for insurance hierarchies
  belongs_to :parent_credentialed_insurance, class_name: 'CredentialedInsurance', optional: true, foreign_key: 'parent_credentialed_insurance_id'
  has_many :child_credentialed_insurances, class_name: 'CredentialedInsurance', foreign_key: 'parent_credentialed_insurance_id', dependent: :nullify

  # Associations
  has_many :clinician_credentialed_insurances, dependent: :destroy
  has_many :therapists, through: :clinician_credentialed_insurances, source: :therapist, foreign_key: 'care_provider_profile_id'

  # Validations
  validates :name, presence: true
  validates :country, presence: true
  validates :network_status, presence: true, inclusion: { in: [0, 1] } # 0 = not in network, 1 = in network
  
  # Callbacks
  before_validation :set_default_country

  # Array validations
  validate :validate_legacy_names_array

  # Scopes
  scope :in_network, -> { where(network_status: 1) }
  scope :out_of_network, -> { where(network_status: 0) }
  scope :by_country, ->(country) { where(country: country) }
  scope :by_state, ->(state) { where(state: state) }
  scope :by_name, ->(name) { where('name ILIKE ?', "%#{name}%") }
  scope :root_insurances, -> { where(parent_credentialed_insurance_id: nil) }

  # Callbacks
  before_validation :set_default_country
  before_validation :normalize_legacy_names_array

  # Helper methods

  def in_network?
    network_status == 1
  end

  def out_of_network?
    network_status == 0
  end

  def display_name
    [name, state].compact.join(' - ')
  end

  def full_name
    parts = [name]
    parts << state if state.present?
    parts << country if country.present? && country != 'US'
    parts.join(', ')
  end

  def root_insurance
    return self if parent_credentialed_insurance_id.nil?
    parent_credentialed_insurance&.root_insurance || self
  end

  private

  def set_default_country
    self.country ||= 'US'
  end

  def validate_legacy_names_array
    self.legacy_names = Array(legacy_names).compact if legacy_names.present?
  end

  def normalize_legacy_names_array
    self.legacy_names = Array(legacy_names).compact if legacy_names.present?
  end
end

