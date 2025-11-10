namespace :import do
  desc "Import patients and guardians from CSV (creates Parent and Student records)"
  task patients_guardians: :environment do
    # Note: This should be run AFTER kinships are imported
    # so that students can be linked to their parents
    importer = Importers::PatientGuardianImporter.new
    importer.import
    
    # Post-import: Validate relationships
    puts "\nValidating patient/guardian relationships..."
    Student.find_each do |student|
      unless Parent.exists?(id: student.parent_id)
        puts "Warning: Parent #{student.parent_id} not found for student #{student.id}"
      end
    end
  end
end

