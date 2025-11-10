class AvailabilityWindow < ApplicationRecord
  # Polymorphic association
  belongs_to :owner, polymorphic: true

  # Validations
  validates :owner_type, presence: true, inclusion: { in: %w[Parent Therapist Student] }
  validates :owner_id, presence: true
  validates :start_date, presence: true
  validate :end_date_after_start_date
  validate :has_availability_data
  validate :validate_availability_json_structure, if: -> { availability_json.present? }

  # Scopes
  scope :for_owner, ->(owner) { where(owner: owner) }
  scope :active, -> { where('end_date IS NULL OR end_date >= ?', Date.today) }
  scope :with_json_format, -> { where.not(availability_json: nil) }
  scope :with_rrule_format, -> { where.not(rrule: nil) }
  scope :by_timezone, ->(tz) { where(timezone: tz) }

  # Callbacks
  before_validation :normalize_availability_json

  # Instance methods

  def overlaps?(other_window)
    return false if end_date && other_window.start_date > end_date
    return false if other_window.end_date && start_date > other_window.end_date
    true
  end

  # Format detection
  def uses_json_format?
    availability_json.present? && availability_json.is_a?(Hash) && availability_json.key?('days')
  end

  def uses_rrule_format?
    rrule.present?
  end

  # JSON format helpers
  def availability_days
    return [] unless uses_json_format?
    availability_json['days'] || []
  end

  def time_blocks_for_day(day_name)
    return [] unless uses_json_format?
    day = availability_days.find { |d| d['day'] == day_name }
    day ? (day['time_blocks'] || []) : []
  end

  def available_on_day?(day_name)
    availability_days.any? { |d| d['day'] == day_name }
  end

  def available_at_time?(day_name, time_string)
    return false unless available_on_day?(day_name)
    time_blocks = time_blocks_for_day(day_name)
    time_blocks.any? do |block|
      block_start = Time.parse(block['start']).seconds_since_midnight
      block_end = block_start + (block['duration'] || 60) * 60
      requested_time = Time.parse(time_string).seconds_since_midnight
      requested_time >= block_start && requested_time < block_end
    end
  end

  # Conversion methods
  def to_json_format
    return availability_json if uses_json_format?
    # Convert rrule to JSON format (simplified - would need rrule parsing library)
    # For now, return empty structure
    { 'days' => [] }
  end

  def to_rrule
    return rrule if uses_rrule_format?
    # Convert JSON format to rrule (would need proper conversion logic)
    nil
  end

  private

  def end_date_after_start_date
    if end_date.present? && start_date.present? && end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def has_availability_data
    unless rrule.present? || availability_json.present?
      errors.add(:base, "must have either rrule or availability_json")
    end
  end

  def validate_availability_json_structure
    return unless availability_json.is_a?(Hash)
    
    if availability_json.key?('days')
      unless availability_json['days'].is_a?(Array)
        errors.add(:availability_json, "days must be an array")
        return
      end

      availability_json['days'].each_with_index do |day, index|
        unless day.is_a?(Hash)
          errors.add(:availability_json, "day at index #{index} must be an object")
          next
        end

        unless day['day'].present?
          errors.add(:availability_json, "day at index #{index} must have a 'day' field")
        end

        if day['time_blocks'].present?
          unless day['time_blocks'].is_a?(Array)
            errors.add(:availability_json, "time_blocks for #{day['day']} must be an array")
            next
          end

          day['time_blocks'].each_with_index do |block, block_index|
            unless block.is_a?(Hash)
              errors.add(:availability_json, "time_block at index #{block_index} for #{day['day']} must be an object")
              next
            end

            unless block['start'].present?
              errors.add(:availability_json, "time_block at index #{block_index} for #{day['day']} must have a 'start' field")
            end

            unless block['duration'].present? || block['end'].present?
              errors.add(:availability_json, "time_block at index #{block_index} for #{day['day']} must have 'duration' or 'end' field")
            end
          end
        end
      end
    end
  end

  def normalize_availability_json
    # Convert string JSON to hash if needed
    if availability_json.is_a?(String)
      begin
        self.availability_json = JSON.parse(availability_json)
      rescue JSON::ParserError => e
        errors.add(:availability_json, "invalid JSON: #{e.message}")
      end
    end

    # Ensure it's a hash with 'days' key
    if availability_json.is_a?(Array)
      # If it's an array of day objects, wrap it in a hash
      self.availability_json = { 'days' => availability_json }
    end

    # Normalize day names (capitalize first letter)
    if availability_json.is_a?(Hash) && availability_json['days'].is_a?(Array)
      availability_json['days'].each do |day|
        day['day'] = day['day'].to_s.capitalize if day['day'].present?
      end
    end
  end
end
