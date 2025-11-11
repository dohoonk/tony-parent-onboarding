class Parent < ApplicationRecord
  include Authorizable
  
  # Password authentication
  has_secure_password

  # Associations
  has_many :students, dependent: :destroy
  has_many :onboarding_sessions, dependent: :destroy
  has_many :referral_members, as: :user, dependent: :destroy
  has_many :referrals, foreign_key: 'submitter_id', dependent: :destroy
  has_many :kinships_as_user_0, class_name: 'Kinship', as: :user_0, dependent: :destroy
  has_many :kinships_as_user_1, class_name: 'Kinship', as: :user_1, dependent: :destroy
  
  # Helper method to get all kinships for this parent
  def kinships
    Kinship.where('(user_0_type = ? AND user_0_id = ?) OR (user_1_type = ? AND user_1_id = ?)', 'Parent', id, 'Parent', id)
  end
  
  has_many :memberships, as: :user, dependent: :destroy
  has_many :organizations, through: :memberships
  has_many :questionnaires, foreign_key: 'respondent_id', dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :auth_provider, presence: true, inclusion: { in: %w[magic_link password] }
  validates :preferred_language, inclusion: { in: %w[eng es fr zh ja ko] }, allow_nil: true
  validate :birthdate_is_valid

  # Scopes
  scope :by_account_status, ->(status) { where(account_status: status) }
  scope :by_preferred_language, ->(lang) { where(preferred_language: lang) }
  scope :with_system_label, ->(label) { where('? = ANY(system_labels)', label) }
  scope :active, -> { where(account_status: 'active') }
  scope :inactive, -> { where.not(account_status: 'active') }

  # Callbacks
  before_validation :normalize_email
  before_validation :normalize_arrays
  after_initialize :set_default_role, if: :new_record?

  # Helper methods

  def full_name
    [first_name, middle_name, last_name].compact.join(' ')
  end

  def display_name
    preferred_name.presence || full_name
  end

  def age
    return nil unless birthdate.present?
    ((Date.today - birthdate) / 365.25).floor
  end

  def active?
    account_status == 'active'
  end

  def has_system_label?(label)
    system_labels.include?(label)
  end

  def address_string
    return nil unless address.present?
    if address.is_a?(Hash)
      parts = [
        address['street'],
        address['city'],
        address['state'],
        address['zip_code']
      ].compact.reject(&:blank?)
      parts.join(', ')
    else
      address.to_s
    end
  end

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def normalize_arrays
    self.system_labels = Array(system_labels).compact if system_labels.present?
  end

  def birthdate_is_valid
    if birthdate.present? && birthdate > Date.today
      errors.add(:birthdate, "cannot be in the future")
    end

    if birthdate.present? && birthdate < 150.years.ago
      errors.add(:birthdate, "is too far in the past")
    end
  end

  def set_default_role
    self.role ||= Authorizable::ROLES[:parent]
  end
end

