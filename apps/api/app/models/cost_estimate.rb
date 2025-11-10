class CostEstimate < ApplicationRecord
  # Associations
  belongs_to :onboarding_session

  # Validations
  validates :onboarding_session_id, uniqueness: true
  validates :min_cost_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :max_cost_cents, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :max_greater_than_min

  # Instance methods
  def min_cost_dollars
    Money.new(min_cost_cents, 'USD')
  end

  def max_cost_dollars
    Money.new(max_cost_cents, 'USD')
  end

  def range_display
    "$#{min_cost_dollars.format(no_cents_if_whole: true)} - $#{max_cost_dollars.format(no_cents_if_whole: true)}"
  end

  private

  def max_greater_than_min
    if min_cost_cents.present? && max_cost_cents.present? && max_cost_cents < min_cost_cents
      errors.add(:max_cost_cents, "must be greater than or equal to minimum cost")
    end
  end
end

