class Parent < ApplicationRecord
  # Associations
  has_many :students, dependent: :destroy
  has_many :onboarding_sessions, dependent: :destroy

  # Validations
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :auth_provider, presence: true, inclusion: { in: %w[magic_link] }

  # Callbacks
  before_validation :normalize_email

  private

  def normalize_email
    self.email = email&.downcase&.strip
  end
end

