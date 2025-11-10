namespace :import do
  desc "Import credentialed insurances from CSV"
  task credentialed_insurances: :environment do
    importer = Importers::CredentialedInsuranceImporter.new
    importer.import
    
    # After import, validate parent insurance relationships
    puts "\nValidating insurance hierarchy..."
    CredentialedInsurance.find_each do |insurance|
      if insurance.parent_credentialed_insurance_id.present? && 
         !CredentialedInsurance.exists?(id: insurance.parent_credentialed_insurance_id)
        puts "Warning: Parent insurance #{insurance.parent_credentialed_insurance_id} not found for #{insurance.id}"
        insurance.update_column(:parent_credentialed_insurance_id, nil)
      end
    end
  end

  desc "Import clinician-credentialed insurance relationships from CSV"
  task clinician_credentialed_insurances: :environment do
    importer = Importers::ClinicianCredentialedInsuranceImporter.new
    importer.import
  end

  desc "Import insurance coverages (policies) from CSV"
  task insurance_coverages: :environment do
    puts "Note: This import creates InsurancePolicy records with basic fields."
    puts "Task 28 will update the InsurancePolicy model to include all CSV fields."
    puts ""
    
    importer = Importers::InsuranceCoverageImporter.new
    importer.import
  end

  desc "Import all insurance-related data"
  task insurance: :environment do
    puts "Importing insurance data in dependency order..."
    puts "\n=== Step 1: Credentialed Insurances ==="
    Rake::Task['import:credentialed_insurances'].invoke
    
    puts "\n=== Step 2: Clinician-Credentialed Insurance Relationships ==="
    Rake::Task['import:clinician_credentialed_insurances'].invoke
    
    puts "\n=== Step 3: Insurance Coverages (Policies) ==="
    Rake::Task['import:insurance_coverages'].invoke
    
    puts "\n\nAll insurance data imported successfully!"
    puts "Note: InsurancePolicy model will be updated in Task 28 to include all CSV fields."
  end
end

