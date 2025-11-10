class AvailabilityWindow < ApplicationRecord
  # Polymorphic association
  belongs_to :owner, polymorphic: true

  # Validations
  validates :owner_type, presence: true, inclusion: { in: %w[Parent Therapist] }
  validates :owner_id, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date

  # Scopes
  scope :for_owner, ->(owner) { where(owner: owner) }
  scope :active, -> { where('end_date IS NULL OR end_date >= ?', Date.today) }

  # Instance methods
  def overlaps?(other_window)
    return false if end_date && other_window.start_date > end_date
    return false if other_window.end_date && start_date > other_window.end_date
    true
  end

  private

  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end
end

