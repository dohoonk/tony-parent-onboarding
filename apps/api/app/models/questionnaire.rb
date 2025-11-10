class Questionnaire < ApplicationRecord
  # Disable STI since we're using questionnaire_type for our own purposes
  self.inheritance_column = nil

  # Associations
  belongs_to :subject, class_name: 'Student', foreign_key: 'subject_id'
  belongs_to :respondent, class_name: 'Parent', foreign_key: 'respondent_id'
  has_one :screener_response, dependent: :nullify # Optional link to screener response

  # Validations
  validates :subject_id, presence: true
  validates :respondent_id, presence: true
  validates :questionnaire_type, presence: true
  validates :language_of_completion, presence: true, inclusion: { in: %w[eng spa fr] } # Add more languages as needed

  # Callbacks
  before_validation :normalize_question_answers
  before_validation :set_default_language

  # Scopes
  scope :by_type, ->(type) { where(questionnaire_type: type) }
  scope :by_subject, ->(subject_id) { where(subject_id: subject_id) }
  scope :by_respondent, ->(respondent_id) { where(respondent_id: respondent_id) }
  scope :completed, -> { where.not(completed_at: nil) }
  scope :in_progress, -> { where.not(started_at: nil).where(completed_at: nil) }
  scope :by_language, ->(lang) { where(language_of_completion: lang) }

  # Questionnaire type to screener key mapping
  # This maps questionnaire types (integers) to screener keys (strings)
  TYPE_TO_SCREENER_KEY = {
    1 => 'phq9',
    2 => 'gad7',
    3 => 'custom_intake', # Example custom questionnaire
    4 => 'family_history', # Example custom questionnaire
    # Add more mappings as needed
  }.freeze

  SCREENER_KEY_TO_TYPE = TYPE_TO_SCREENER_KEY.invert.freeze

  # Helper methods
  def screener_key
    TYPE_TO_SCREENER_KEY[questionnaire_type]
  end

  def completed?
    completed_at.present?
  end

  def in_progress?
    started_at.present? && completed_at.nil?
  end

  def duration_seconds
    return nil unless started_at.present? && completed_at.present?
    (completed_at - started_at).to_i
  end

  def mark_started!
    return if started_at.present?
    self.started_at = Time.current
    save(validate: false) if persisted?
  end

  def mark_completed!
    return if completed_at.present?
    self.completed_at = Time.current
    save(validate: false) if persisted?
  end

  # Find or create associated screener response
  def link_to_screener_response(onboarding_session)
    return nil unless screener_key.present?

    screener = Screener.find_by(key: screener_key)
    return nil unless screener

    # Find or create screener response
    screener_response = ScreenerResponse.find_or_initialize_by(
      onboarding_session: onboarding_session,
      screener: screener
    )

    # Map question_answers to screener response format if needed
    screener_response.answers_json = question_answers
    screener_response.score = score if score.present?
    screener_response.save

    # Link questionnaire to screener response
    screener_response.update!(questionnaire: self) if screener_response.persisted? && persisted?

    screener_response
  end

  private

  def normalize_question_answers
    self.question_answers ||= {}
  end

  def set_default_language
    self.language_of_completion ||= 'eng'
  end
end

