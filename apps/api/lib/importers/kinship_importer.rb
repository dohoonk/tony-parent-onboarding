module Importers
  class KinshipImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/kinships.csv')
      super(csv_path, Kinship)
    end

    protected

    def extract_id(row)
      # Use composite key for idempotency (order-agnostic)
      ids = [row['user_0_id'], row['user_1_id']].sort
      "#{ids[0]}-#{ids[1]}"
    end

    def record_exists?(composite_id)
      id1, id2 = composite_id.split('-')
      Kinship.where(
        '(user_0_id = ? AND user_1_id = ?) OR (user_0_id = ? AND user_1_id = ?)',
        id1, id2, id2, id1
      ).exists?
    end

    def build_attributes(row)
      user_0_id = parse_uuid(row, 'user_0_id')
      user_1_id = parse_uuid(row, 'user_1_id')
      
      # Determine user types by trying to find in Parent and Student
      user_0_parent = Parent.find_by(id: user_0_id)
      user_0_student = Student.find_by(id: user_0_id)
      user_1_parent = Parent.find_by(id: user_1_id)
      user_1_student = Student.find_by(id: user_1_id)
      
      unless (user_0_parent || user_0_student) && (user_1_parent || user_1_student)
        raise "Users not found: user_0_id=#{user_0_id}, user_1_id=#{user_1_id}"
      end
      
      user_0_type = user_0_parent ? 'Parent' : 'Student'
      user_1_type = user_1_parent ? 'Parent' : 'Student'
      
      # Parse JSONB fields
      migration_details = parse_json_field(row, 'migration_details', default: {})
      
      {
        user_0_id: user_0_id,
        user_0_type: user_0_type,
        user_1_id: user_1_id,
        user_1_type: user_1_type,
        kind: parse_integer(row, 'kind', default: 0),
        user_0_label: row['user_0_label'].presence,
        user_1_label: row['user_1_label'].presence,
        guardian_can_be_contacted: parse_boolean(row, 'guardian_can_be_contacted', default: false),
        migration_details: migration_details,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

