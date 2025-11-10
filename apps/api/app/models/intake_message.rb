class IntakeMessage < ApplicationRecord
  # Associations
  belongs_to :onboarding_session

  # Enums
  enum :role, { user: 'user', assistant: 'assistant', system: 'system' }, prefix: true

  # Validations
  validates :role, presence: true
  validates :content, presence: true

  # Scopes
  scope :chronological, -> { order(created_at: :asc) }
  scope :by_role, ->(role) { where(role: role) }

  # Callbacks
  after_create :de_identify_content_async

  private

  def de_identify_content_async
    # TODO: Enqueue job to strip PHI from content
    # DeIdentifyContentJob.perform_later(id)
  end
end

