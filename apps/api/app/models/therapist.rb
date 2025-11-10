class Therapist < ApplicationRecord
  # Associations
  belongs_to :supervisor, class_name: 'Therapist', optional: true, foreign_key: 'supervisor_id'
  belongs_to :associate_supervisor, class_name: 'Therapist', optional: true, foreign_key: 'associate_supervisor_id'
  has_many :supervisees, class_name: 'Therapist', foreign_key: 'supervisor_id', dependent: :nullify
  has_many :associate_supervisees, class_name: 'Therapist', foreign_key: 'associate_supervisor_id', dependent: :nullify
  
  # Associations
  has_many :clinician_credentialed_insurances, dependent: :destroy, foreign_key: 'care_provider_profile_id'
  has_many :credentialed_insurances, through: :clinician_credentialed_insurances

  # Future associations (to be added when other models are created)
  # has_many :availability_windows, dependent: :destroy
  # has_many :appointments, dependent: :destroy

  # Validations
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :npi_number, format: { with: /\A\d{10}\z/ }, allow_blank: true
  validates :employment_type, inclusion: { 
    in: ['W2 Hourly', '1099 Contractor', 'Full-time', 'Part-time', 'Contractor', nil] 
  }, allow_blank: true
  validates :clinical_role, inclusion: { 
    in: ['Therapist', 'Clinician', 'Supervisor', 'Associate', nil] 
  }, allow_blank: true
  
  # Array validations
  validate :validate_array_fields
  
  # Scopes
  scope :active, -> { where(active: true) }
  scope :by_state, ->(state) { where(primary_state: state) }
  scope :by_employment_type, ->(type) { where(employment_type: type) }
  scope :by_clinical_role, ->(role) { where(clinical_role: role) }
  scope :with_specialty, ->(specialty) { where('specialties @> ARRAY[?]::text[]', specialty) }
  scope :with_language, ->(language) { where('care_languages @> ARRAY[?]::text[]', language) }
  scope :licensed_in_state, ->(state) { where('licensed_states @> ARRAY[?]::text[]', state) }
  scope :available, -> { where('capacity_available > 0') }
  scope :with_capacity, -> { where('capacity_total > 0') }

  # Callbacks
  before_validation :normalize_email
  before_save :calculate_capacity_available
  before_save :extract_profile_data

  # Helper methods
  
  def full_name
    [first_name, middle_name, last_name].compact.join(' ').presence || preferred_name
  end

  def display_name
    preferred_name.presence || full_name
  end

  def capacity_utilization_percentage
    return 0 if capacity_total.zero?
    (capacity_filled.to_f / capacity_total * 100).round(2)
  end

  def has_capacity?
    capacity_available > 0
  end

  def has_capacity_for_daybreak?
    capacity_available_daybreak > 0
  end

  def has_capacity_for_kaiser?
    capacity_available_kaiser > 0
  end

  def is_supervisor?
    supervisees.exists?
  end

  def is_supervised?
    supervisor_id.present?
  end

  def licensed_in?(state)
    licensed_states.include?(state)
  end

  def speaks_language?(language)
    care_languages.include?(language)
  end

  def has_specialty?(specialty)
    specialties.include?(specialty)
  end

  def uses_modality?(modality)
    modalities.include?(modality)
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def calculate_capacity_available
    self.capacity_available = capacity_total - capacity_filled
    self.capacity_available_daybreak = capacity_total_daybreak - capacity_filled_daybreak
    self.capacity_available_kaiser = capacity_total_kaiser - capacity_filled_kaiser
  end

  def extract_profile_data
    # Extract commonly accessed fields from profile_data JSONB if they exist
    return unless profile_data.present?

    # Extract bio if not already set
    self.bio ||= profile_data['bio'] if profile_data['bio'].present?
    
    # Extract NPI if not already set
    self.npi_number ||= profile_data['npi_number'] || profile_data['npi'] if profile_data['npi_number'].present? || profile_data['npi'].present?
    
    # Extract specialties if not already set
    if specialties.empty? && profile_data['specialties'].present?
      self.specialties = Array(profile_data['specialties'])
    end
    
    # Extract modalities if not already set
    if modalities.empty? && profile_data['modalities'].present?
      self.modalities = Array(profile_data['modalities'])
    end
  end

  def validate_array_fields
    # Ensure array fields are arrays
    self.specialties = Array(specialties) if specialties.present?
    self.modalities = Array(modalities) if modalities.present?
    self.licenses = Array(licenses) if licenses.present?
    self.licensed_states = Array(licensed_states) if licensed_states.present?
    self.care_languages = Array(care_languages) if care_languages.present?
    self.ethnicity_and_demographics = Array(ethnicity_and_demographics) if ethnicity_and_demographics.present?
    self.religions = Array(religions) if religions.present?
    self.system_labels = Array(system_labels) if system_labels.present?
  end
end

