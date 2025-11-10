class Screener < ApplicationRecord
  # Associations
  has_many :screener_responses, dependent: :destroy

  # Validations
  validates :key, presence: true, uniqueness: true
  validates :title, presence: true
  validates :version, presence: true
  validates :items_json, presence: true

  # Scopes
  scope :active, -> { where(active: true) } # Assuming we might add an `active` boolean later

  # Class methods
  def self.find_by_key!(key)
    find_by!(key: key)
  end

  # Instance methods
  def items
    items_json || {}
  end
end

