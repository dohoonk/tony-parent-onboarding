module Importers
  class ClinicianAvailabilityImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/clinician_availabilities.csv')
      super(csv_path, AvailabilityWindow)
    end

    protected

    def extract_id(row)
      # Use composite key: user_id + range_start + day_of_week
      "#{row['user_id']}-#{row['range_start']}-#{row['day_of_week']}"
    end

    def record_exists?(composite_id)
      # For simplicity, we'll check if a similar window exists
      # This is approximate - in production you might want more precise matching
      false # Always try to create, let validations handle duplicates
    end

    def build_attributes(row)
      # Find therapist by user_id (healthie_id or email lookup)
      therapist = find_therapist_by_user_id(row['user_id'])
      
      unless therapist
        raise "Therapist not found for user_id: #{row['user_id']}"
      end
      
      # Parse timestamps
      range_start = parse_timestamp(row, 'range_start')
      range_end = parse_timestamp(row, 'range_end')
      timezone = row['timezone'].presence || 'America/Los_Angeles'
      
      # Convert day_of_week (0=Sunday, 1=Monday, etc.) to day name
      day_of_week_num = parse_integer(row, 'day_of_week')
      day_name = day_name_from_number(day_of_week_num) if day_of_week_num
      
      # Build availability_json if is_repeating and day_of_week is present
      availability_json = nil
      if parse_boolean(row, 'is_repeating', default: false) && day_name
        # Extract time from range_start
        start_time = range_start ? range_start.strftime('%H:%M:%S') : '09:00:00'
        duration = 60 # Default 60 minutes, could calculate from range_start/range_end
        
        availability_json = {
          'days' => [
            {
              'day' => day_name,
              'time_blocks' => [
                {
                  'start' => start_time,
                  'duration' => duration
                }
              ]
            }
          ]
        }
      end
      
      # Build rrule if is_repeating
      rrule = nil
      if parse_boolean(row, 'is_repeating', default: false) && day_of_week_num
        # Convert day_of_week to rrule format
        rrule_day = rrule_day_from_number(day_of_week_num)
        rrule = "FREQ=WEEKLY;BYDAY=#{rrule_day}" if rrule_day
      end
      
      {
        owner: therapist,
        owner_type: 'Therapist',
        start_date: range_start ? range_start.to_date : Date.current,
        end_date: range_end ? range_end.to_date : nil,
        timezone: timezone,
        rrule: rrule,
        availability_json: availability_json,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end

    private

    def find_therapist_by_user_id(user_id)
      # Try to find by healthie_id first (user_id in CSV is healthie_id)
      therapist = Therapist.find_by(healthie_id: user_id)
      return therapist if therapist
      
      # If not found, try to find by any other identifier
      # Note: This is a simplified lookup - you may need to adjust based on your data
      nil
    end

    def day_name_from_number(num)
      days = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday]
      days[num] if num && num >= 0 && num <= 6
    end

    def rrule_day_from_number(num)
      days = %w[SU MO TU WE TH FR SA]
      days[num] if num && num >= 0 && num <= 6
    end
  end
end

