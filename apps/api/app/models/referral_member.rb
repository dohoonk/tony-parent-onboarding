class ReferralMember < ApplicationRecord
  # Polymorphic association for user (can be Parent or Student)
  belongs_to :user, polymorphic: true
  belongs_to :referral

  # Validations
  validates :referral_id, presence: true
  validates :user_id, presence: true
  validates :user_type, presence: true, inclusion: { in: %w[Parent Student] }
  validates :role, presence: true, inclusion: { in: [0, 1] } # 0 = student, 1 = parent/guardian
  validates :user_id, uniqueness: { scope: [:referral_id, :user_type], message: 'already a member of this referral' }

  # Callbacks
  before_validation :set_user_type_from_role, if: -> { user_type.blank? && role.present? }
  before_validation :normalize_data

  # Scopes
  scope :students, -> { where(user_type: 'Student', role: 0) }
  scope :parents, -> { where(user_type: 'Parent', role: 1) }
  scope :for_referral, ->(referral_id) { where(referral_id: referral_id) }

  # Helper methods
  def student?
    user_type == 'Student' && role == 0
  end

  def parent?
    user_type == 'Parent' && role == 1
  end

  private

  def set_user_type_from_role
    # If role is 0, it's a student; if 1, it's a parent
    # But we need the actual user to determine type, so this is a fallback
    # The import script should set user_type correctly
    self.user_type = role == 0 ? 'Student' : 'Parent' if user_type.blank?
  end

  def normalize_data
    self.data ||= {}
  end
end

