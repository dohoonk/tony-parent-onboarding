class ScreenerResponse < ApplicationRecord
  # Associations
  belongs_to :onboarding_session
  belongs_to :screener

  # Validations
  validates :answers_json, presence: true
  validates :screener_id, uniqueness: { scope: :onboarding_session_id, message: "has already been completed for this session" }

  # Accessors
  def answers
    answers_json || {}
  end

  def answers=(value)
    self.answers_json = value
  end

  # Instance methods
  def calculate_score
    # TODO: Implement scoring logic based on screener type
    # This would be different for PHQ-9, GAD-7, etc.
  end

  def severity_level
    return nil unless score.present?

    case screener.key
    when 'phq9'
      case score
      when 0..4 then 'minimal'
      when 5..9 then 'mild'
      when 10..14 then 'moderate'
      when 15..19 then 'moderately_severe'
      when 20..27 then 'severe'
      end
    when 'gad7'
      case score
      when 0..4 then 'minimal'
      when 5..9 then 'mild'
      when 10..14 then 'moderate'
      when 15..21 then 'severe'
      end
    end
  end
end

