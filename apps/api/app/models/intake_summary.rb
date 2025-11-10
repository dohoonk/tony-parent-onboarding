class IntakeSummary < ApplicationRecord
  # Associations
  belongs_to :onboarding_session

  # Validations
  validates :onboarding_session_id, uniqueness: true

  # Accessors for JSON fields
  def concerns
    concerns_json || []
  end

  def concerns=(value)
    self.concerns_json = value
  end

  def goals
    goals_json || []
  end

  def goals=(value)
    self.goals_json = value
  end

  def risk_flags
    risk_flags_json || []
  end

  def risk_flags=(value)
    self.risk_flags_json = value
  end
end

