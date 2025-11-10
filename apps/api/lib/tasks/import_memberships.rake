namespace :import do
  desc "Import memberships from CSV"
  task memberships: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/memberships.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing memberships from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        membership_id = row['id']
        next if membership_id.blank?
        
        # Skip if already exists (idempotent)
        if Membership.exists?(id: membership_id)
          skipped += 1
          next
        end
        
        # Skip deleted records
        if row['_fivetran_deleted'] == 'true'
          skipped += 1
          next
        end
        
        # Find user (Parent or Student)
        user_id = row['user_id']
        user = nil
        user_type = nil
        
        # Try to find as Student first (most common)
        user = Student.find_by(id: user_id)
        if user
          user_type = 'Student'
        else
          # Try to find as Parent
          user = Parent.find_by(id: user_id)
          if user
            user_type = 'Parent'
          end
        end
        
        unless user
          puts "Warning: User not found for user_id #{user_id}, skipping membership #{membership_id}"
          skipped += 1
          next
        end
        
        # Find organization
        organization = Organization.find_by(id: row['organization_id'])
        unless organization
          puts "Warning: Organization not found for organization_id #{row['organization_id']}, skipping membership #{membership_id}"
          skipped += 1
          next
        end
        
        # Parse JSONB fields
        profile_data = {}
        if row['profile_data'].present? && row['profile_data'] != '{}'
          begin
            profile_data = JSON.parse(row['profile_data'])
          rescue JSON::ParserError
            profile_data = {}
          end
        end
        
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
        
        # Build membership attributes
        membership_attrs = {
          id: membership_id,
          user: user,
          user_type: user_type,
          organization: organization,
          census_person_id: row['census_person_id'].presence,
          profile_data: profile_data,
          migration_details: migration_details,
          created_at: parse_timestamp.call(row['created_at']) || Time.current,
          updated_at: parse_timestamp.call(row['updated_at']) || Time.current
        }
        
        membership = Membership.new(membership_attrs)
        
        if membership.save
          imported += 1
          print '.' if imported % 10 == 0
        else
          puts "\nError saving membership #{membership_id}: #{membership.errors.full_messages.join(', ')}"
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

