class Student < ApplicationRecord
  # Associations
  belongs_to :parent
  has_many :onboarding_sessions, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :referral_members, as: :user, dependent: :destroy
  has_many :kinships_as_user_0, class_name: 'Kinship', as: :user_0, dependent: :destroy
  has_many :kinships_as_user_1, class_name: 'Kinship', as: :user_1, dependent: :destroy
  
  # Helper method to get all kinships for this student
  def kinships
    Kinship.where('(user_0_type = ? AND user_0_id = ?) OR (user_1_type = ? AND user_1_id = ?)', 'Student', id, 'Student', id)
  end
  
  has_many :memberships, as: :user, dependent: :destroy
  has_many :organizations, through: :memberships

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

