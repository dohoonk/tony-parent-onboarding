module Importers
  class PatientAvailabilityImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/patient_availabilities.csv')
      super(csv_path, AvailabilityWindow)
    end

    protected

    def build_attributes(row)
      # Find parent or student by user_id
      user_id = parse_uuid(row, 'user_id')
      parent = Parent.find_by(id: user_id)
      student = Student.find_by(id: user_id)
      
      owner = parent || student
      unless owner
        raise "Parent or Student not found for user_id: #{user_id}"
      end
      
      owner_type = parent ? 'Parent' : 'Student'
      
      # Parse availability JSON (already in correct format)
      availability_data = parse_json_field(row, 'availability', default: [])
      
      # Normalize to expected format: {days: [...]}
      # The CSV has it as an array, but model expects {days: [...]}
      availability_json = if availability_data.is_a?(Array)
        { 'days' => availability_data }
      elsif availability_data.is_a?(Hash) && availability_data.key?('days')
        availability_data
      else
        { 'days' => [] }
      end
      
      # Set default date range (no end date = ongoing)
      start_date = Date.current
      end_date = nil # Ongoing availability
      
      {
        owner: owner,
        owner_type: owner_type,
        start_date: start_date,
        end_date: end_date,
        timezone: 'America/Los_Angeles', # Default, could be extracted from user profile
        availability_json: availability_json,
        rrule: nil, # Using JSON format
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

