namespace :import do
  desc "Import referrals from CSV"
  task referrals: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/referrals.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing referrals from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        referral_id = row['id']
        next if referral_id.blank?
        
        # Skip if already exists (idempotent)
        if Referral.exists?(id: referral_id)
          skipped += 1
          next
        end
        
        # Skip deleted records
        if row['_fivetran_deleted'] == 'true'
          skipped += 1
          next
        end
        
        # Find submitter (parent)
        submitter = Parent.find_by(id: row['submitter_id'])
        unless submitter
          puts "Warning: Parent not found for submitter_id #{row['submitter_id']}, skipping referral #{referral_id}"
          skipped += 1
          next
        end
        
        # Find organization
        organization = Organization.find_by(id: row['organization_id'])
        unless organization
          puts "Warning: Organization not found for organization_id #{row['organization_id']}, skipping referral #{referral_id}"
          skipped += 1
          next
        end
        
        # Parse JSONB data field
        data = {}
        if row['data'].present? && row['data'] != '{}'
          begin
            data = JSON.parse(row['data'])
          rescue JSON::ParserError
            data = {}
          end
        end
        
        # Parse array fields
        allowed_coverage = []
        if row['allowed_coverage'].present?
          begin
            # Handle array format: ["insurance","self_pay"]
            coverage_str = row['allowed_coverage'].gsub(/[\[\]"]/, '')
            allowed_coverage = coverage_str.split(',').map(&:strip).reject(&:blank?)
          rescue
            allowed_coverage = []
          end
        end
        
        care_provider_requirements = []
        if row['care_provider_requirements'].present?
          begin
            req_str = row['care_provider_requirements'].gsub(/[\[\]"]/, '')
            care_provider_requirements = req_str.split(',').map(&:strip).reject(&:blank?)
          rescue
            care_provider_requirements = []
          end
        end
        
        system_labels = []
        if row['system_labels'].present?
          begin
            labels_str = row['system_labels'].gsub(/[\[\]"]/, '')
            system_labels = labels_str.split(',').map(&:strip).reject(&:blank?)
          rescue
            system_labels = []
          end
        end
        
        # Parse notes (may contain JSON)
        notes = nil
        if row['notes'].present?
          begin
            # Try to parse as JSON first
            parsed_notes = JSON.parse(row['notes'])
            notes = parsed_notes.is_a?(Hash) ? parsed_notes.to_json : row['notes']
          rescue JSON::ParserError
            notes = row['notes']
          end
        end
        
        # Parse timestamps
        parse_timestamp = ->(str) {
          return nil if str.blank?
          Time.parse(str) rescue nil
        }
        
        # Build referral attributes
        referral_attrs = {
          id: referral_id,
          submitter: submitter,
          organization: organization,
          service_kind: row['service_kind']&.to_i,
          concerns: row['concerns'],
          data: data,
          contract_id: row['contract_id'].presence,
          intake_id: row['intake_id'].presence,
          care_provider_id: row['care_provider_id'].presence,
          terms_kind: row['terms_kind']&.to_i,
          appointment_kind: row['appointment_kind']&.to_i,
          planned_sessions: row['planned_sessions']&.to_i,
          initial_scheduled_sessions: row['initial_scheduled_sessions']&.to_i,
          collect_coverage: row['collect_coverage'] == 'true',
          allowed_coverage: allowed_coverage,
          collection_rule: row['collection_rule']&.to_i,
          self_responsibility_required: row['self_responsibility_required'] == 'true',
          care_provider_requirements: care_provider_requirements,
          system_labels: system_labels,
          tzdb: row['tzdb'] || 'America/Los_Angeles',
          notes: notes,
          disenrollment_category: row['disenrollment_category'],
          zendesk_ticket_id: row['zendesk_ticket_id'],
          market_id: row['market_id'].presence,
          referred_at: parse_timestamp.call(row['referred_at']),
          ready_for_scheduling_at: parse_timestamp.call(row['ready_for_scheduling_at']),
          scheduled_at: parse_timestamp.call(row['scheduled_at']),
          onboarding_completed_at: parse_timestamp.call(row['onboarding_completed_at']),
          enrolled_at: parse_timestamp.call(row['enrolled_at']),
          disenrolled_at: parse_timestamp.call(row['disenrolled_at']),
          request_rejected_at: parse_timestamp.call(row['request_rejected_at']),
          excluded_at: parse_timestamp.call(row['excluded_at']),
          created_at: parse_timestamp.call(row['created_at']) || Time.current,
          updated_at: parse_timestamp.call(row['updated_at']) || Time.current
        }
        
        referral = Referral.new(referral_attrs)
        
        if referral.save
          imported += 1
          print '.' if imported % 10 == 0
        else
          puts "\nError saving referral #{referral_id}: #{referral.errors.full_messages.join(', ')}"
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

  desc "Import referral members from CSV"
  task referral_members: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/referral_members.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing referral members from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        member_id = row['id']
        next if member_id.blank?
        
        # Skip if already exists (idempotent)
        if ReferralMember.exists?(id: member_id)
          skipped += 1
          next
        end
        
        # Skip deleted records
        if row['_fivetran_deleted'] == 'true'
          skipped += 1
          next
        end
        
        # Find referral
        referral = Referral.find_by(id: row['referral_id'])
        unless referral
          puts "Warning: Referral not found for referral_id #{row['referral_id']}, skipping member #{member_id}"
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
          puts "Warning: User not found for user_id #{user_id}, skipping member #{member_id}"
          skipped += 1
          next
        end
        
        # Determine user_type from role if not set
        role = row['role']&.to_i || 0
        if user_type.blank?
          user_type = role == 0 ? 'Student' : 'Parent'
        end
        
        # Parse JSONB data field
        data = {}
        if row['data'].present? && row['data'] != '{}'
          begin
            data = JSON.parse(row['data'])
          rescue JSON::ParserError
            data = {}
          end
        end
        
        # Parse timestamps
        parse_timestamp = ->(str) {
          return nil if str.blank?
          Time.parse(str) rescue nil
        }
        
        # Build member attributes
        member_attrs = {
          id: member_id,
          referral: referral,
          user: user,
          user_type: user_type,
          role: role,
          data: data,
          created_at: parse_timestamp.call(row['created_at']) || Time.current,
          updated_at: parse_timestamp.call(row['updated_at']) || Time.current
        }
        
        member = ReferralMember.new(member_attrs)
        
        if member.save
          imported += 1
          print '.' if imported % 10 == 0
        else
          puts "\nError saving referral member #{member_id}: #{member.errors.full_messages.join(', ')}"
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

  desc "Import all referral data (referrals and members)"
  task all_referrals: :environment do
    puts "Importing all referral data...\n\n"
    
    Rake::Task['import:referrals'].invoke
    puts "\n"
    Rake::Task['import:referral_members'].invoke
  end
end

