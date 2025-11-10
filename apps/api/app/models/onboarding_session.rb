class OnboardingSession < ApplicationRecord
  # Associations
  belongs_to :parent
  belongs_to :student
  has_many :intake_messages, dependent: :destroy
  has_one :intake_summary, dependent: :destroy
  has_many :screener_responses, dependent: :destroy
  has_many :insurance_cards, dependent: :destroy
  has_one :insurance_policy, dependent: :destroy
  has_one :cost_estimate, dependent: :destroy
  has_many :appointments, dependent: :destroy

  # Enums
  enum :status, { draft: 'draft', active: 'active', completed: 'completed', abandoned: 'abandoned' }, prefix: true

  # Validations
  validates :status, presence: true
  validates :current_step, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :parent_id, uniqueness: { scope: :student_id, message: "already has an active session for this student" }, if: -> { status_active? || status_draft? }

  # Scopes
  scope :active, -> { where(status: 'active') }
  scope :completed, -> { where(status: 'completed') }
  scope :in_progress, -> { where(status: ['draft', 'active']) }

  # Callbacks
  after_update :mark_completed_at, if: -> { saved_change_to_status? && status_completed? }

  private

  def mark_completed_at
    update_column(:completed_at, Time.current) if completed_at.nil?
  end
end

