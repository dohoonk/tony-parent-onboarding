namespace :import do
  desc "Import clinician availabilities from CSV"
  task clinician_availabilities: :environment do
    require 'csv'
    
    csv_path = Rails.root.join('../../devdocs/clinician_availabilities.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing clinician availabilities from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    # Map day_of_week numbers to day names (0=Sunday, 1=Monday, etc.)
    DAY_NAMES = %w[Sunday Monday Tuesday Wednesday Thursday Friday Saturday].freeze
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        user_id = row['user_id']
        next if user_id.blank?
        
        # Find therapist by healthie_id or email (assuming user_id maps to healthie_id)
        therapist = Therapist.find_by(healthie_id: user_id.to_s)
        
        unless therapist
          skipped += 1
          next
        end
        
        # Parse availability data
        day_of_week = row['day_of_week']&.to_i
        range_start = row['range_start']
        range_end = row['range_end']
        timezone = row['timezone'] || 'America/Los_Angeles'
        is_repeating = row['is_repeating'] == 'true'
        
        next unless day_of_week && range_start && range_end
        
        # Convert day_of_week (0-6) to day name
        day_name = DAY_NAMES[day_of_week]
        next unless day_name
        
        # Parse time range
        start_time = Time.parse(range_start).utc
        end_time = Time.parse(range_end).utc
        
        # Calculate duration in minutes
        duration_minutes = ((end_time - start_time) / 60).to_i
        
        # Format time as HH:MM:SS
        start_time_str = start_time.strftime('%H:%M:%S')
        
        # Find or create availability window for this therapist
        # Group by day and timezone to avoid duplicates
        availability_window = AvailabilityWindow.find_or_initialize_by(
          owner_type: 'Therapist',
          owner_id: therapist.id,
          timezone: timezone,
          start_date: Date.current
        )
        
        # Initialize availability_json if needed
        availability_window.availability_json ||= { 'days' => [] }
        availability_window.availability_json['days'] ||= []
        
        # Find or create day entry
        day_entry = availability_window.availability_json['days'].find { |d| d['day'] == day_name }
        
        unless day_entry
          day_entry = { 'day' => day_name, 'time_blocks' => [] }
          availability_window.availability_json['days'] << day_entry
        end
        
        # Add time block if not already present
        time_block = {
          'start' => start_time_str,
          'duration' => duration_minutes
        }
        
        unless day_entry['time_blocks'].any? { |tb| tb['start'] == start_time_str && tb['duration'] == duration_minutes }
          day_entry['time_blocks'] << time_block
        end
        
        # Set end_date if provided
        if row['end_on'].present?
          availability_window.end_date = Date.parse(row['end_on'])
        end
        
        if availability_window.save
          imported += 1
        else
          puts "Error saving availability for therapist #{therapist.id}: #{availability_window.errors.full_messages.join(', ')}"
          errors += 1
        end
        
      rescue => e
        puts "Error processing row: #{e.message}"
        errors += 1
      end
    end
    
    puts "\nImport complete:"
    puts "  Imported: #{imported}"
    puts "  Skipped: #{skipped}"
    puts "  Errors: #{errors}"
  end

  desc "Import patient availabilities from CSV"
  task patient_availabilities: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/patient_availabilities.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing patient availabilities from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        user_id = row['user_id']
        availability_json_str = row['availability']
        
        next if user_id.blank? || availability_json_str.blank?
        
        # Find student by ID (assuming user_id is student_id)
        # Note: This may need adjustment based on actual data model
        student = Student.find_by(id: user_id)
        
        unless student
          skipped += 1
          next
        end
        
        # Parse JSON availability
        availability_data = JSON.parse(availability_json_str)
        
        # Ensure it's in the correct format
        availability_json = if availability_data.is_a?(Array)
          { 'days' => availability_data }
        else
          availability_data
        end
        
        # Find or create availability window for this student
        availability_window = AvailabilityWindow.find_or_initialize_by(
          owner_type: 'Student',
          owner_id: student.id,
          start_date: Date.current
        )
        
        availability_window.availability_json = availability_json
        availability_window.timezone = 'America/Los_Angeles' # Default timezone
        
        if availability_window.save
          imported += 1
        else
          puts "Error saving availability for student #{student.id}: #{availability_window.errors.full_messages.join(', ')}"
          errors += 1
        end
        
      rescue JSON::ParserError => e
        puts "Error parsing JSON for user_id #{row['user_id']}: #{e.message}"
        errors += 1
      rescue => e
        puts "Error processing row: #{e.message}"
        errors += 1
      end
    end
    
    puts "\nImport complete:"
    puts "  Imported: #{imported}"
    puts "  Skipped: #{skipped}"
    puts "  Errors: #{errors}"
  end

  desc "Import all availabilities (clinician and patient)"
  task all_availabilities: :environment do
    puts "Importing all availabilities...\n\n"
    
    Rake::Task['import:clinician_availabilities'].invoke
    puts "\n"
    Rake::Task['import:patient_availabilities'].invoke
  end
end

