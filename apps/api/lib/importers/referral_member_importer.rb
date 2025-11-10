module Importers
  class ReferralMemberImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/referral_members.csv')
      super(csv_path, ReferralMember)
    end

    protected

    def extract_id(row)
      # Use composite key for idempotency check
      "#{row['referral_id']}-#{row['user_id']}"
    end

    def record_exists?(composite_id)
      referral_id, user_id = composite_id.split('-')
      ReferralMember.exists?(referral_id: referral_id, user_id: user_id)
    end

    def build_attributes(row)
      referral = find_record(Referral, row['referral_id'], required: true)
      user_id = parse_uuid(row, 'user_id')
      
      # Determine user type by trying to find in Parent and Student
      parent = Parent.find_by(id: user_id)
      student = Student.find_by(id: user_id)
      
      unless parent || student
        raise "User not found for user_id: #{user_id}"
      end
      
      user_type = parent ? 'Parent' : 'Student'
      role = parse_integer(row, 'role', default: 0) # 0 = student, 1 = parent/guardian
      
      # Ensure role matches user type
      if user_type == 'Parent' && role != 1
        role = 1
      elsif user_type == 'Student' && role != 0
        role = 0
      end
      
      # Parse JSONB data
      data = parse_json_field(row, 'data', default: {})
      
      {
        referral_id: referral.id,
        user_id: user_id,
        user_type: user_type,
        role: role,
        data: data,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

