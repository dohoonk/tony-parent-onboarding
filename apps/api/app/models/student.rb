class Student < ApplicationRecord
  # Associations
  belongs_to :parent
  has_many :onboarding_sessions, dependent: :destroy
  has_many :appointments, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true
  validates :language, presence: true
  validate :date_of_birth_is_valid

  # Scopes
  scope :by_age_range, ->(min_age, max_age) {
    where(date_of_birth: (Date.today - max_age.years)..(Date.today - min_age.years))
  }

  # Instance methods
  def age
    return nil unless date_of_birth.present?
    ((Date.today - date_of_birth) / 365.25).floor
  end

  private

  def date_of_birth_is_valid
    if date_of_birth.present? && date_of_birth > Date.today
      errors.add(:date_of_birth, "cannot be in the future")
    end

    if date_of_birth.present? && date_of_birth < 100.years.ago
      errors.add(:date_of_birth, "is too far in the past")
    end
  end
end

