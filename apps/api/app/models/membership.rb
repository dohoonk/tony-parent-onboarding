class Membership < ApplicationRecord
  # Polymorphic association for user (can be Parent or Student)
  belongs_to :user, polymorphic: true
  belongs_to :organization

  # Validations
  validates :user_id, presence: true
  validates :user_type, presence: true, inclusion: { in: %w[Parent Student] }
  validates :organization_id, presence: true
  validates :user_id, uniqueness: { scope: [:user_type, :organization_id], message: 'already a member of this organization' }

  # Callbacks
  before_validation :normalize_profile_data
  before_validation :normalize_migration_details

  # Scopes
  scope :for_user, ->(user) { where(user_id: user.id, user_type: user.class.name) }
  scope :for_organization, ->(organization_id) { where(organization_id: organization_id) }
  scope :parents, -> { where(user_type: 'Parent') }
  scope :students, -> { where(user_type: 'Student') }

  # Helper methods
  def parent?
    user_type == 'Parent'
  end

  def student?
    user_type == 'Student'
  end

  private

  def normalize_profile_data
    self.profile_data ||= {}
  end

  def normalize_migration_details
    self.migration_details ||= {}
  end
end

