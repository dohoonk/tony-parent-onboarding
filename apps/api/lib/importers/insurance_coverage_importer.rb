module Importers
  class InsuranceCoverageImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/insurance_coverages.csv')
      super(csv_path, InsurancePolicy)
    end

    protected

    def build_attributes(row)
      # Note: This importer creates InsurancePolicy records, but the CSV has many more fields
      # than the current model. Task 28 will update the InsurancePolicy model to match.
      # For now, we'll import the basic fields that exist in the current model.
      
      # Find onboarding session by user_id (parent)
      user_id = parse_uuid(row, 'user_id')
      parent = Parent.find_by(id: user_id)
      
      unless parent
        raise "Parent not found for user_id: #{user_id}"
      end
      
      # Find or create an onboarding session for this parent
      # Note: This is a simplified approach - in production, you'd want to match to the correct session
      onboarding_session = parent.onboarding_sessions.first || parent.onboarding_sessions.create!(
        student: parent.students.first || parent.students.create!(
          first_name: 'Student',
          last_name: parent.last_name,
          date_of_birth: 10.years.ago,
          language: 'eng'
        )
      )
      
      # Parse arrays
      system_labels = parse_array_field(row, 'system_labels', default: [])
      
      # Parse JSONB fields
      migration_details = parse_json_field(row, 'migration_details', default: {})
      profile_data = parse_json_field(row, 'profile_data', default: {})
      
      {
        onboarding_session_id: onboarding_session.id,
        member_id: row['member_id'].presence,
        group_number: row['group_id'].presence, # Note: CSV uses group_id, model uses group_number
        payer_name: row['insurance_company_name'].presence || 'Unknown',
        # Note: The following fields will be added in Task 28 migration:
        # front_card_url, back_card_url, plan_holder fields, etc.
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

