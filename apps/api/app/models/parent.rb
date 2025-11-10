class Parent < ApplicationRecord
  include Authorizable

  # Associations
  has_many :students, dependent: :destroy
  has_many :onboarding_sessions, dependent: :destroy
  has_many :referral_members, as: :user, dependent: :destroy
  has_many :referrals, foreign_key: 'submitter_id', dependent: :destroy

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

