namespace :import do
  desc "Import kinships from CSV"
  task kinships: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/kinships.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing kinships from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        kinship_id = row['id']
        next if kinship_id.blank?
        
        # Skip if already exists (idempotent)
        if Kinship.exists?(id: kinship_id)
          skipped += 1
          next
        end
        
        # Skip deleted records
        if row['_fivetran_deleted'] == 'true'
          skipped += 1
          next
        end
        
        # Find user_0 (can be Parent or Student)
        user_0_id = row['user_0_id']
        user_0 = nil
        user_0_type = nil
        
        # Try to find as Student first (most common in parent-child relationships)
        user_0 = Student.find_by(id: user_0_id)
        if user_0
          user_0_type = 'Student'
        else
          # Try to find as Parent
          user_0 = Parent.find_by(id: user_0_id)
          if user_0
            user_0_type = 'Parent'
          end
        end
        
        unless user_0
          puts "Warning: User_0 not found for user_0_id #{user_0_id}, skipping kinship #{kinship_id}"
          skipped += 1
          next
        end
        
        # Find user_1 (can be Parent or Student)
        user_1_id = row['user_1_id']
        user_1 = nil
        user_1_type = nil
        
        # Try to find as Student first
        user_1 = Student.find_by(id: user_1_id)
        if user_1
          user_1_type = 'Student'
        else
          # Try to find as Parent
          user_1 = Parent.find_by(id: user_1_id)
          if user_1
            user_1_type = 'Parent'
          end
        end
        
        unless user_1
          puts "Warning: User_1 not found for user_1_id #{user_1_id}, skipping kinship #{kinship_id}"
          skipped += 1
          next
        end
        
        # Parse JSONB migration_details field
        migration_details = {}
        if row['migration_details'].present? && row['migration_details'] != '{}'
          begin
            migration_details = JSON.parse(row['migration_details'])
          rescue JSON::ParserError
            migration_details = {}
          end
        end
        
        # Parse timestamps
        parse_timestamp = ->(str) {
          return nil if str.blank?
          Time.parse(str) rescue nil
        }
        
        # Build kinship attributes
        kinship_attrs = {
          id: kinship_id,
          user_0: user_0,
          user_0_type: user_0_type,
          user_1: user_1,
          user_1_type: user_1_type,
          kind: row['kind']&.to_i || 1,
          user_0_label: row['user_0_label'],
          user_1_label: row['user_1_label'],
          guardian_can_be_contacted: row['guardian_can_be_contacted'] == 'true',
          migration_details: migration_details,
          created_at: parse_timestamp.call(row['created_at']) || Time.current,
          updated_at: parse_timestamp.call(row['updated_at']) || Time.current
        }
        
        kinship = Kinship.new(kinship_attrs)
        
        if kinship.save
          imported += 1
          print '.' if imported % 10 == 0
        else
          puts "\nError saving kinship #{kinship_id}: #{kinship.errors.full_messages.join(', ')}"
          errors += 1
        end
        
      rescue => e
        puts "\nError processing row #{row['id']}: #{e.message}"
        puts e.backtrace.first(3).join("\n")
        errors += 1
      end
    end
    
    puts "\n\nImport complete:"
    puts "  Imported: #{imported}"
    puts "  Skipped: #{skipped}"
    puts "  Errors: #{errors}"
  end
end

