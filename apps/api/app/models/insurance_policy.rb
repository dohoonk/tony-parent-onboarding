class InsurancePolicy < ApplicationRecord
  # Associations
  belongs_to :onboarding_session
  belongs_to :user, polymorphic: true, optional: true
  belongs_to :created_by, class_name: 'Parent', foreign_key: 'created_by_id', optional: true

  # Encryptions (PHI/PII)
  encrypts :member_id, deterministic: true  # Deterministic for search/lookup
  encrypts :group_number                     # Non-deterministic for max security
  encrypts :group_id                         # Non-deterministic for max security
  # Plan holder information (PHI)
  encrypts :plan_holder_first_name
  encrypts :plan_holder_last_name
  encrypts :plan_holder_dob
  encrypts :plan_holder_street_address
  encrypts :plan_holder_zip_code
  encrypts :plan_holder_legal_gender

  # Validations
  validates :payer_name, presence: true
  validates :member_id, presence: true
  validates :onboarding_session_id, uniqueness: true
  validates :kind, inclusion: { in: [0, 1, 2] }, allow_nil: true # 0: unknown, 1: individual, 2: family
  validates :level, inclusion: { in: [0, 1, 2, 3] }, allow_nil: true # 0: unknown, 1: bronze, 2: silver, 3: gold
  validates :eligibility, inclusion: { in: [0, 1, 2, 3, 4] }, allow_nil: true # 0: unknown, 1: active, 2: pending, 3: expired, 4: terminated
  validates :plan_holder_country, inclusion: { in: %w[US CA MX] }, allow_nil: true

  # Scopes
  scope :by_kind, ->(kind) { where(kind: kind) }
  scope :by_level, ->(level) { where(level: level) }
  scope :by_eligibility, ->(eligibility) { where(eligibility: eligibility) }
  scope :by_insurance_company, ->(name) { where(insurance_company_name: name) }
  scope :with_system_label, ->(label) { where('? = ANY(system_labels)', label) }
  scope :in_network, -> { with_system_label('in_network') }
  scope :out_of_network, -> { where.not(id: in_network.select(:id)) }

  # Callbacks
  before_validation :normalize_fields
  before_validation :normalize_arrays

  # Helper methods

  def plan_holder_full_name
    [plan_holder_first_name, plan_holder_last_name].compact.join(' ')
  end

  def plan_holder_full_address
    parts = [
      plan_holder_street_address,
      plan_holder_city,
      plan_holder_state,
      plan_holder_zip_code
    ].compact.reject(&:blank?)
    parts.join(', ')
  end

  def insurance_company_name_or_payer_name
    insurance_company_name.presence || payer_name
  end

  def in_network?
    system_labels.include?('in_network')
  end

  def out_of_network?
    !in_network?
  end

  def active?
    eligibility == 1
  end

  def has_card_images?
    front_card_url.present? || back_card_url.present?
  end

  def has_plan_holder_info?
    plan_holder_first_name.present? || plan_holder_last_name.present?
  end

  def has_openpm_data?
    openpm_insurance_organization_id.present? || openpm_coverage_id.present?
  end

  private

  def normalize_fields
    self.member_id = member_id&.strip&.upcase
    self.group_number = group_number&.strip&.upcase
    self.group_id = group_id&.strip&.upcase if group_id.present?
    self.payer_name = payer_name&.strip
    self.insurance_company_name = insurance_company_name&.strip if insurance_company_name.present?
    self.plan_holder_first_name = plan_holder_first_name&.strip if plan_holder_first_name.present?
    self.plan_holder_last_name = plan_holder_last_name&.strip if plan_holder_last_name.present?
    self.plan_holder_city = plan_holder_city&.strip if plan_holder_city.present?
    self.plan_holder_state = plan_holder_state&.strip&.upcase if plan_holder_state.present?
    self.plan_holder_zip_code = plan_holder_zip_code&.strip if plan_holder_zip_code.present?
    self.plan_holder_country = plan_holder_country&.strip&.upcase if plan_holder_country.present?
  end

  def normalize_arrays
    self.system_labels = Array(system_labels).compact if system_labels.present?
  end
end

