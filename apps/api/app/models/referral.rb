class Referral < ApplicationRecord
  # Associations
  belongs_to :submitter, class_name: 'Parent', foreign_key: 'submitter_id'
  belongs_to :organization
  belongs_to :contract, optional: true
  belongs_to :care_provider, class_name: 'Therapist', foreign_key: 'care_provider_id', optional: true
  has_many :referral_members, dependent: :destroy

  # Validations
  validates :submitter_id, presence: true
  validates :organization_id, presence: true
  validates :service_kind, presence: true
  validates :terms_kind, presence: true
  validates :appointment_kind, presence: true

  # Array validations
  validate :validate_arrays

  # Scopes
  scope :by_organization, ->(org_id) { where(organization_id: org_id) }
  scope :by_submitter, ->(parent_id) { where(submitter_id: parent_id) }
  scope :referred, -> { where.not(referred_at: nil) }
  scope :ready_for_scheduling, -> { where.not(ready_for_scheduling_at: nil) }
  scope :scheduled, -> { where.not(scheduled_at: nil) }
  scope :enrolled, -> { where.not(enrolled_at: nil) }
  scope :disenrolled, -> { where.not(disenrolled_at: nil) }
  scope :rejected, -> { where.not(request_rejected_at: nil) }

  # Callbacks
  before_validation :normalize_arrays

  # Status helper methods (based on timestamps)
  def status
    return 'disenrolled' if disenrolled_at.present?
    return 'enrolled' if enrolled_at.present?
    return 'scheduled' if scheduled_at.present?
    return 'ready_for_scheduling' if ready_for_scheduling_at.present?
    return 'onboarding_completed' if onboarding_completed_at.present?
    return 'rejected' if request_rejected_at.present?
    return 'referred' if referred_at.present?
    'pending'
  end

  def referred?
    referred_at.present?
  end

  def ready_for_scheduling?
    ready_for_scheduling_at.present?
  end

  def scheduled?
    scheduled_at.present?
  end

  def enrolled?
    enrolled_at.present?
  end

  def disenrolled?
    disenrolled_at.present?
  end

  def rejected?
    request_rejected_at.present?
  end

  # Status transition methods
  def mark_referred!
    update!(referred_at: Time.current) unless referred_at.present?
  end

  def mark_ready_for_scheduling!
    update!(ready_for_scheduling_at: Time.current) unless ready_for_scheduling_at.present?
  end

  def mark_scheduled!
    update!(scheduled_at: Time.current) unless scheduled_at.present?
  end

  def mark_enrolled!
    update!(enrolled_at: Time.current) unless enrolled_at.present?
  end

  def mark_disenrolled!(category: nil)
    update!(
      disenrolled_at: Time.current,
      disenrollment_category: category
    ) unless disenrolled_at.present?
  end

  def mark_rejected!(cause: nil)
    return if request_rejected_at.present?
    
    notes_text = notes.to_s
    notes_text += "\nRejection cause: #{cause}" if cause.present?
    
    update!(
      request_rejected_at: Time.current,
      notes: notes_text
    )
  end

  # Helper methods to get associated users
  def students
    referral_members.where(user_type: 'Student').map(&:user).select { |u| u.is_a?(Student) }
  end

  def parents
    referral_members.where(user_type: 'Parent').map(&:user).select { |u| u.is_a?(Parent) }
  end

  private

  def validate_arrays
    self.allowed_coverage = Array(allowed_coverage).compact if allowed_coverage.present?
    self.care_provider_requirements = Array(care_provider_requirements).compact if care_provider_requirements.present?
    self.system_labels = Array(system_labels).compact if system_labels.present?
  end

  def normalize_arrays
    self.allowed_coverage = Array(allowed_coverage).compact if allowed_coverage.present?
    self.care_provider_requirements = Array(care_provider_requirements).compact if care_provider_requirements.present?
    self.system_labels = Array(system_labels).compact if system_labels.present?
    self.data ||= {}
  end
end

