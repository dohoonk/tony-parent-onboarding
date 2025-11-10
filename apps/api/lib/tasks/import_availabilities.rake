namespace :import do
  desc "Import clinician availabilities from CSV"
  task clinician_availabilities: :environment do
    puts "Note: Clinician availabilities are converted from rrule-style to JSON format."
    puts "This is a simplified conversion - you may need to adjust based on your needs."
    puts ""
    
    importer = Importers::ClinicianAvailabilityImporter.new
    importer.import
    
    # Post-import: Validate owner relationships
    puts "\nValidating availability window owners..."
    AvailabilityWindow.where(owner_type: 'Therapist').find_each do |window|
      unless Therapist.exists?(id: window.owner_id)
        puts "Warning: Therapist #{window.owner_id} not found for availability window #{window.id}"
        window.destroy
      end
    end
  end

  desc "Import patient availabilities from CSV"
  task patient_availabilities: :environment do
    importer = Importers::PatientAvailabilityImporter.new
    importer.import
    
    # Post-import: Validate owner relationships
    puts "\nValidating availability window owners..."
    AvailabilityWindow.where(owner_type: ['Parent', 'Student']).find_each do |window|
      owner_class = window.owner_type.constantize
      unless owner_class.exists?(id: window.owner_id)
        puts "Warning: #{window.owner_type} #{window.owner_id} not found for availability window #{window.id}"
        window.destroy
      end
    end
  end

  desc "Import all availability data"
  task availabilities: :environment do
    puts "Importing availability data..."
    puts "\n=== Step 1: Clinician Availabilities ==="
    Rake::Task['import:clinician_availabilities'].invoke
    
    puts "\n=== Step 2: Patient Availabilities ==="
    Rake::Task['import:patient_availabilities'].invoke
    
    puts "\n\nAll availability data imported successfully!"
  end
end
