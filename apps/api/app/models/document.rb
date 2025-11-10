class Document < ApplicationRecord
  # Validations
  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :label, presence: true
  validates :label, uniqueness: { scope: :version, message: 'and version combination already exists' }

  # Callbacks
  before_validation :normalize_urls
  before_validation :normalize_names
  before_validation :normalize_checkboxes

  # Scopes
  scope :by_label, ->(label) { where(label: label) }
  scope :by_version, ->(version) { where(version: version) }
  scope :latest, -> { order(version: :desc) }
  scope :for_language, ->(lang) { where("urls ? :lang", lang: lang) }

  # Helper methods
  def url_for_language(lang = 'eng')
    urls[lang] || urls['eng'] || urls.values.first
  end

  def name_for_language(lang = 'eng')
    names[lang] || names['eng'] || names.values.first
  end

  def available_languages
    urls.keys
  end

  def latest_version?
    Document.where(label: label).maximum(:version) == version
  end

  private

  def normalize_urls
    self.urls ||= {}
  end

  def normalize_names
    self.names ||= {}
  end

  def normalize_checkboxes
    # Keep checkboxes as-is, but ensure it's not nil if needed
    self.checkboxes ||= '' if checkboxes.nil?
  end
end

