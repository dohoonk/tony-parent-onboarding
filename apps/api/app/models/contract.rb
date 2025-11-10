class Contract < ApplicationRecord
  # Associations
  has_many :org_contracts, dependent: :destroy
  has_many :organizations, through: :org_contracts

  # Validations
  validates :effective_date, presence: true
  validate :end_date_after_effective_date, if: -> { end_date.present? }
  
  # Array validations
  validate :validate_services_array

  # Scopes
  scope :active, -> { where('effective_date <= ? AND (end_date IS NULL OR end_date >= ?)', Date.current, Date.current) }
  scope :expired, -> { where('end_date < ?', Date.current) }
  scope :upcoming, -> { where('effective_date > ?', Date.current) }
  scope :by_date_range, ->(start_date, end_date) {
    where('(effective_date <= ? AND (end_date IS NULL OR end_date >= ?))', end_date, start_date)
  }
  scope :with_service, ->(service) { where('services @> ARRAY[?]::text[]', service) }

  # Callbacks
  before_validation :normalize_services_array

  # Helper methods

  def active?
    effective_date <= Date.current && (end_date.nil? || end_date >= Date.current)
  end

  def expired?
    end_date.present? && end_date < Date.current
  end

  def upcoming?
    effective_date > Date.current
  end

  def has_service?(service)
    services.include?(service)
  end

  def term_by_kind(kind)
    return nil unless terms.is_a?(Array)
    terms.find { |term| term['kind'] == kind }
  end

  def sponsored_term
    term_by_kind('sponsored')
  end

  def onsite_term
    term_by_kind('onsite')
  end

  def support_term
    term_by_kind('support')
  end

  private

  def end_date_after_effective_date
    return unless effective_date.present? && end_date.present?
    
    if end_date < effective_date
      errors.add(:end_date, 'must be after effective date')
    end
  end

  def validate_services_array
    self.services = Array(services) if services.present?
  end

  def normalize_services_array
    self.services = Array(services).compact if services.present?
  end
end

