class Organization < ApplicationRecord
  # Self-referential associations for hierarchy (districts -> schools)
  belongs_to :parent_organization, class_name: 'Organization', optional: true, foreign_key: 'parent_organization_id'
  has_many :child_organizations, class_name: 'Organization', foreign_key: 'parent_organization_id', dependent: :nullify

  # Associations
  has_many :org_contracts, dependent: :destroy
  has_many :contracts, through: :org_contracts

  has_many :memberships, dependent: :destroy

  # Validations
  validates :slug, presence: true, uniqueness: true
  validates :name, presence: true
  validates :kind, presence: true, inclusion: { in: %w[district school] }
  
  # Validate hierarchy: schools must have a parent (district)
  validate :school_must_have_parent

  # Scopes
  scope :districts, -> { where(kind: 'district') }
  scope :schools, -> { where(kind: 'school') }
  scope :enabled, -> { where.not(enabled_at: nil) }
  scope :disabled, -> { where(enabled_at: nil) }
  scope :by_market, ->(market_id) { where(market_id: market_id) }
  scope :by_parent, ->(parent_id) { where(parent_organization_id: parent_id) }

  # Callbacks
  before_validation :normalize_slug

  # Helper methods

  def district?
    kind == 'district'
  end

  def school?
    kind == 'school'
  end

  def enabled?
    enabled_at.present?
  end

  def disabled?
    enabled_at.nil?
  end

  def enable!
    update!(enabled_at: Time.current)
  end

  def disable!
    update!(enabled_at: nil)
  end

  # Hierarchy navigation

  def root_district
    return self if district? && parent_organization_id.nil?
    return parent_organization.root_district if parent_organization
    nil
  end

  def all_schools
    return [] if school?
    child_organizations.schools
  end

  def all_descendants
    descendants = []
    child_organizations.each do |child|
      descendants << child
      descendants.concat(child.all_descendants)
    end
    descendants
  end

  def full_path
    path = [name]
    current = self
    while current.parent_organization
      current = current.parent_organization
      path.unshift(current.name)
    end
    path.join(' > ')
  end

  private

  def normalize_slug
    self.slug = slug&.downcase&.strip&.parameterize if slug.present?
  end

  def school_must_have_parent
    if school? && parent_organization_id.nil?
      errors.add(:parent_organization_id, 'must be present for schools')
    end
  end
end

