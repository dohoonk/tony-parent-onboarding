class Parent < ApplicationRecord
  include Authorizable

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

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :auth_provider, presence: true, inclusion: { in: %w[magic_link] }

  # Callbacks
  before_validation :normalize_email
  after_initialize :set_default_role, if: :new_record?

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end

  def set_default_role
    self.role ||= Authorizable::ROLES[:parent]
  end
end

