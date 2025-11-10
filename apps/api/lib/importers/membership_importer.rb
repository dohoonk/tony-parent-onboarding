module Importers
  class MembershipImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/memberships.csv')
      super(csv_path, Membership)
    end

    protected

    def extract_id(row)
      # Use composite key for idempotency check
      "#{row['organization_id']}-#{row['user_id']}"
    end

    def record_exists?(composite_id)
      org_id, user_id = composite_id.split('-')
      Membership.exists?(organization_id: org_id, user_id: user_id)
    end

    def build_attributes(row)
      organization = find_record(Organization, row['organization_id'], required: true)
      user_id = parse_uuid(row, 'user_id')
      
      # Determine user type by trying to find in Parent and Student
      parent = Parent.find_by(id: user_id)
      student = Student.find_by(id: user_id)
      
      unless parent || student
        raise "User not found for user_id: #{user_id}"
      end
      
      user_type = parent ? 'Parent' : 'Student'
      
      # Parse JSONB fields
      profile_data = parse_json_field(row, 'profile_data', default: {})
      migration_details = parse_json_field(row, 'migration_details', default: {})
      
      {
        organization_id: organization.id,
        user_id: user_id,
        user_type: user_type,
        census_person_id: row['census_person_id'].presence,
        profile_data: profile_data,
        migration_details: migration_details,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

