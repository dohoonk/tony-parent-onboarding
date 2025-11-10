class Appointment < ApplicationRecord
  # Associations
  belongs_to :onboarding_session
  belongs_to :student
  # TODO: belongs_to :therapist (when therapist model exists)

  # Enums
  enum :status, {
    scheduled: 'scheduled',
    confirmed: 'confirmed',
    completed: 'completed',
    cancelled: 'cancelled',
    no_show: 'no_show'
  }, prefix: true

  # Validations
  validates :therapist_id, presence: true
  validates :scheduled_at, presence: true
  validates :duration_minutes, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true
  validate :scheduled_in_future, on: :create

  # Scopes
  scope :upcoming, -> { where('scheduled_at > ?', Time.current).where(status: ['scheduled', 'confirmed']) }
  scope :past, -> { where('scheduled_at < ?', Time.current) }
  scope :for_therapist, ->(therapist_id) { where(therapist_id: therapist_id) }

  # Instance methods
  def end_time
    scheduled_at + duration_minutes.minutes
  end

  def can_cancel?
    status_scheduled? || status_confirmed?
  end

  def can_reschedule?
    status_scheduled? || status_confirmed?
  end

  private

  def scheduled_in_future
    if scheduled_at.present? && scheduled_at < Time.current
      errors.add(:scheduled_at, "must be in the future")
    end
  end
end

