namespace :import do
  desc "Import clinicians (therapists) from CSV"
  task clinicians: :environment do
    importer = Importers::TherapistImporter.new
    importer.import
    
    # After import, update supervisor relationships
    puts "\nUpdating supervisor relationships..."
    Therapist.find_each do |therapist|
      if therapist.supervisor_id.present? && !Therapist.exists?(id: therapist.supervisor_id)
        puts "Warning: Supervisor #{therapist.supervisor_id} not found for therapist #{therapist.id}"
        therapist.update_column(:supervisor_id, nil)
      end
      if therapist.associate_supervisor_id.present? && !Therapist.exists?(id: therapist.associate_supervisor_id)
        puts "Warning: Associate supervisor #{therapist.associate_supervisor_id} not found for therapist #{therapist.id}"
        therapist.update_column(:associate_supervisor_id, nil)
      end
    end
  end

  desc "Import organizations from CSV"
  task organizations: :environment do
    importer = Importers::OrganizationImporter.new
    importer.import
    
    # After import, validate parent organization relationships
    puts "\nValidating organization hierarchy..."
    Organization.find_each do |org|
      if org.parent_organization_id.present? && !Organization.exists?(id: org.parent_organization_id)
        puts "Warning: Parent organization #{org.parent_organization_id} not found for #{org.id}"
        org.update_column(:parent_organization_id, nil)
      end
    end
  end

  desc "Import contracts from CSV"
  task contracts: :environment do
    importer = Importers::ContractImporter.new
    importer.import
  end

  desc "Import organization-contract relationships from CSV"
  task org_contracts: :environment do
    importer = Importers::OrgContractImporter.new
    importer.import
  end

  desc "Import all core entities (clinicians, organizations, contracts, org_contracts)"
  task core_entities: :environment do
    puts "Importing core entities in dependency order..."
    puts "\n=== Step 1: Organizations ==="
    Rake::Task['import:organizations'].invoke
    
    puts "\n=== Step 2: Contracts ==="
    Rake::Task['import:contracts'].invoke
    
    puts "\n=== Step 3: Clinicians ==="
    Rake::Task['import:clinicians'].invoke
    
    puts "\n=== Step 4: Organization-Contract Relationships ==="
    Rake::Task['import:org_contracts'].invoke
    
    puts "\n\nAll core entities imported successfully!"
  end
end

