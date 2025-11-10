class Kinship < ApplicationRecord
  # Polymorphic associations for both users
  belongs_to :user_0, polymorphic: true
  belongs_to :user_1, polymorphic: true

  # Validations
  validates :user_0_id, presence: true
  validates :user_0_type, presence: true, inclusion: { in: %w[Parent Student] }
  validates :user_1_id, presence: true
  validates :user_1_type, presence: true, inclusion: { in: %w[Parent Student] }
  validates :kind, presence: true
  validates :user_0_id, uniqueness: { scope: [:user_0_type, :user_1_id, :user_1_type], message: 'relationship already exists' }
  validate :users_are_different
  validate :valid_relationship_types

  # Callbacks
  before_validation :normalize_migration_details

  # Scopes
  scope :for_user, ->(user) { where('(user_0_id = ? AND user_0_type = ?) OR (user_1_id = ? AND user_1_type = ?)', user.id, user.class.name, user.id, user.class.name) }
  scope :parent_child, -> { where(kind: 1) }
  scope :guardian_contactable, -> { where(guardian_can_be_contacted: true) }

  # Helper methods
  def parent_child?
    kind == 1
  end

  def other_user(user)
    return user_1 if user_0 == user
    return user_0 if user_1 == user
    nil
  end

  def parent
    return user_0 if user_0_type == 'Parent'
    return user_1 if user_1_type == 'Parent'
    nil
  end

  def student
    return user_0 if user_0_type == 'Student'
    return user_1 if user_1_type == 'Student'
    nil
  end

  private

  def users_are_different
    if user_0_id == user_1_id && user_0_type == user_1_type
      errors.add(:base, 'user_0 and user_1 must be different')
    end
  end

  def valid_relationship_types
    # Ensure at least one parent and one student for parent-child relationships
    if kind == 1 && !((user_0_type == 'Parent' && user_1_type == 'Student') || (user_0_type == 'Student' && user_1_type == 'Parent'))
      errors.add(:base, 'parent-child relationship must be between a Parent and a Student')
    end
  end

  def normalize_migration_details
    self.migration_details ||= {}
  end
end

