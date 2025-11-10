module Importers
  class PatientGuardianImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/patients_and_guardians_anonymized.csv')
      super(csv_path, Parent) # Use Parent as default, but we'll handle both models
    end

    def import
      validate_csv_exists!
      
      puts "Importing patients and guardians from #{csv_path}..."
      start_time = Time.current
      
      CSV.foreach(csv_path, headers: true).with_index do |row, index|
        process_row(row, index + 1)
      end
      
      duration = Time.current - start_time
      print_summary(duration)
      
      stats
    end

    protected

    def process_row(row, row_number)
      @row_number = row_number
      begin
        record_id = extract_id(row)
        return if record_id.blank?
        
        # Skip deleted records
        if deleted?(row)
          stats[:skipped] += 1
          return
        end
        
        role = parse_integer(row, 'role', default: 0) # 0 = student, 1 = parent/guardian
        
        if role == 0
          # Import as Student
          import_student(row, record_id)
        else
          # Import as Parent
          import_parent(row, record_id)
        end
        
      rescue => e
        handle_processing_error(e, row, row_number)
      end
    end

    def extract_id(row)
      row['id']
    end

    def record_exists?(id)
      # Check both Parent and Student tables
      Parent.exists?(id: id) || Student.exists?(id: id)
    end

    def deleted?(row)
      row['_fivetran_deleted'] == 'true'
    end

    private

    def import_parent(row, parent_id)
      # Skip if already exists
      if Parent.exists?(id: parent_id)
        stats[:skipped] += 1
        return
      end
      
      # Parse arrays
      system_labels = parse_array_field(row, 'system_labels', default: [])
      licenses = parse_array_field(row, 'licenses', default: [])
      licensed_states = parse_array_field(row, 'licensed_states', default: [])
      
      # Parse JSONB fields
      profile_data = parse_json_field(row, 'profile_data', default: {})
      migration_details = parse_json_field(row, 'migration_details', default: {})
      supabase_metadata = parse_json_field(row, 'supabase_metadata', default: {})
      
      # Parse address (could be JSON or string)
      address_data = parse_json_field(row, 'address', default: {})
      
      parent_attrs = {
        id: parent_id,
        email: row['email'],
        phone: row['phone'].presence,
        first_name: row['first_name'],
        middle_name: row['middle_name'].presence,
        last_name: row['last_name'],
        preferred_name: row['preferred_name'].presence,
        preferred_pronoun: row['preferred_pronoun'].presence,
        title: row['title'].presence,
        preferred_language: row['preferred_language'].presence || 'eng',
        legal_gender: row['legal_gender'].presence,
        birthdate: parse_date(row, 'birthdate'),
        healthie_id: row['healthie_id'].presence,
        account_status: row['account_status'].presence,
        system_labels: system_labels,
        auth_provider: 'magic_link', # Default
        role: Authorizable::ROLES[:parent], # Default role
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
      
      parent = Parent.new(parent_attrs)
      
      if parent.save
        stats[:imported] += 1
        print_progress if stats[:imported] % 10 == 0
      else
        handle_save_error(parent, row_number)
      end
    end

    def import_student(row, student_id)
      # Skip if already exists
      if Student.exists?(id: student_id)
        stats[:skipped] += 1
        return
      end
      
      # Find parent via kinship relationship
      # Look for a kinship where this student is user_0 or user_1
      kinship = Kinship.where(
        '(user_0_id = ? AND user_0_type = ?) OR (user_1_id = ? AND user_1_type = ?)',
        student_id, 'Student', student_id, 'Student'
      ).where(kind: 1).first # kind 1 = parent-child
      
      parent = nil
      if kinship
        parent = kinship.parent
      end
      
      # If no parent found via kinship, try to find by email (might be same as parent)
      # Or create a placeholder parent
      unless parent
        parent_email = row['email']
        parent = Parent.find_by(email: parent_email) if parent_email.present?
      end
      
      # If still no parent, create a minimal placeholder
      unless parent
        parent = Parent.create!(
          email: "parent_#{student_id}@placeholder.test",
          first_name: 'Parent',
          last_name: row['last_name'] || 'Unknown',
          auth_provider: 'magic_link',
          role: Authorizable::ROLES[:parent]
        )
      end
      
      student_attrs = {
        id: student_id,
        parent_id: parent.id,
        first_name: row['first_name'],
        middle_name: row['middle_name'].presence,
        last_name: row['last_name'],
        preferred_name: row['preferred_name'].presence,
        date_of_birth: parse_date(row, 'birthdate'),
        language: row['preferred_language'].presence || 'eng',
        legal_gender: row['legal_gender'].presence,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
      
      student = Student.new(student_attrs)
      
      if student.save
        stats[:imported] += 1
        print_progress if stats[:imported] % 10 == 0
      else
        handle_save_error(student, @row_number || 0)
      end
    end

    def handle_save_error(record, row_number)
      error_msg = "Row #{row_number} (#{record.id || 'new'}): #{record.errors.full_messages.join(', ')}"
      stats[:errors] += 1
      stats[:error_details] << error_msg
      puts "\n#{error_msg}"
    end

    def print_progress
      print '.'
      $stdout.flush
    end

    def handle_processing_error(error, row, row_number)
      error_msg = "Row #{row_number} (#{row['id'] || 'unknown'}): #{error.message}"
      stats[:errors] += 1
      stats[:error_details] << error_msg
      puts "\n#{error_msg}"
      puts error.backtrace.first(3).join("\n") if Rails.env.development?
    end

    def print_summary(duration)
      puts "\n\nImport complete (#{duration.round(2)}s):"
      puts "  Imported: #{stats[:imported]}"
      puts "  Skipped: #{stats[:skipped]}"
      puts "  Errors: #{stats[:errors]}"
      
      if stats[:errors] > 0 && stats[:error_details].any?
        puts "\nFirst 10 errors:"
        stats[:error_details].first(10).each do |error|
          puts "  - #{error}"
        end
      end
    end
  end
end

