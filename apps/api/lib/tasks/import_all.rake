namespace :import do
  desc "Import all test data from CSV files in the correct dependency order"
  task all: :environment do
    puts "=" * 80
    puts "IMPORTING ALL TEST DATA"
    puts "=" * 80
    puts "\nThis will import all CSV data in the correct dependency order."
    puts "Each step will be executed sequentially.\n\n"
    
    start_time = Time.current
    
    # Phase 1: Core entities (no dependencies)
    puts "\n" + "=" * 80
    puts "PHASE 1: Core Entities"
    puts "=" * 80
    puts "\nStep 1.1: Importing Organizations..."
    Rake::Task['import:organizations'].invoke
    
    puts "\nStep 1.2: Importing Contracts..."
    Rake::Task['import:contracts'].invoke
    
    puts "\nStep 1.3: Importing Org Contracts..."
    Rake::Task['import:org_contracts'].invoke
    
    puts "\nStep 1.4: Importing Credentialed Insurances..."
    Rake::Task['import:credentialed_insurances'].invoke
    
    puts "\nStep 1.5: Importing Therapists..."
    Rake::Task['import:therapists'].invoke
    
    puts "\nStep 1.6: Importing Clinician Credentialed Insurances..."
    Rake::Task['import:clinician_credentialed_insurances'].invoke
    
    puts "\nStep 1.7: Importing Documents..."
    Rake::Task['import:documents'].invoke
    
    # Phase 2: Patients and Guardians (must come before students and relationships)
    puts "\n" + "=" * 80
    puts "PHASE 2: Patients and Guardians"
    puts "=" * 80
    puts "\nStep 2.1: Importing Patients and Guardians..."
    puts "Note: This creates both Parent and Student records."
    Rake::Task['import:patients_guardians'].invoke
    
    # Phase 3: Relationships (depends on patients/guardians)
    puts "\n" + "=" * 80
    puts "PHASE 3: Relationships"
    puts "=" * 80
    puts "\nStep 3.1: Importing Kinships..."
    Rake::Task['import:kinships'].invoke
    
    puts "\nStep 3.2: Importing Memberships..."
    Rake::Task['import:memberships'].invoke
    
    # Phase 4: Referrals (depends on organizations, contracts, parents, students)
    puts "\n" + "=" * 80
    puts "PHASE 4: Referrals"
    puts "=" * 80
    puts "\nStep 4.1: Importing Referrals..."
    Rake::Task['import:referrals'].invoke
    
    puts "\nStep 4.2: Importing Referral Members..."
    Rake::Task['import:referral_members'].invoke
    
    # Phase 5: Availability (depends on therapists, parents, students)
    puts "\n" + "=" * 80
    puts "PHASE 5: Availability"
    puts "=" * 80
    puts "\nStep 5.1: Importing Clinician Availabilities..."
    Rake::Task['import:clinician_availabilities'].invoke
    
    puts "\nStep 5.2: Importing Patient Availabilities..."
    Rake::Task['import:patient_availabilities'].invoke
    
    # Phase 6: Insurance (depends on parents, students)
    puts "\n" + "=" * 80
    puts "PHASE 6: Insurance"
    puts "=" * 80
    puts "\nStep 6.1: Importing Insurance Policies..."
    Rake::Task['import:insurance_policies'].invoke
    
    puts "\nStep 6.2: Importing Insurance Coverages..."
    Rake::Task['import:insurance_coverages'].invoke
    
    # Phase 7: Questionnaires (depends on students, parents)
    puts "\n" + "=" * 80
    puts "PHASE 7: Questionnaires"
    puts "=" * 80
    puts "\nStep 7.1: Importing Questionnaires..."
    Rake::Task['import:questionnaires'].invoke
    
    duration = Time.current - start_time
    
    puts "\n" + "=" * 80
    puts "IMPORT COMPLETE"
    puts "=" * 80
    puts "\nTotal time: #{duration.round(2)} seconds"
    puts "\nAll test data has been imported successfully!"
    puts "\nYou can now verify the data in your database."
  end
  
  desc "Show import task dependencies and order"
  task help: :environment do
    puts <<~HELP
      CSV Import System
      =================
      
      This system provides idempotent CSV import tasks for all test data.
      All importers extend BaseCsvImporter for consistent error handling.
      
      Master Import Task
      ------------------
      rake import:all
        Imports all data in the correct dependency order.
        This is the recommended way to import all test data at once.
      
      Individual Import Tasks
      -----------------------
      The following tasks can be run individually:
      
      Phase 1: Core Entities (no dependencies)
        rake import:organizations
        rake import:contracts
        rake import:org_contracts
        rake import:credentialed_insurances
        rake import:therapists
        rake import:clinician_credentialed_insurances
        rake import:documents
      
      Phase 2: Patients and Guardians
        rake import:patients_guardians
          Creates both Parent and Student records from patients_and_guardians_anonymized.csv
          Note: Students will be linked to parents via kinships (imported in Phase 3)
      
      Phase 3: Relationships
        rake import:kinships
        rake import:memberships
      
      Phase 4: Referrals
        rake import:referrals
        rake import:referral_members
      
      Phase 5: Availability
        rake import:clinician_availabilities
        rake import:patient_availabilities
        rake import:availabilities (runs both)
      
      Phase 6: Insurance
        rake import:insurance_policies
        rake import:insurance_coverages
        rake import:insurance (runs both)
      
      Phase 7: Questionnaires
        rake import:questionnaires
      
      Composite Tasks
      --------------
      rake import:relationships (runs referrals, referral_members, kinships, memberships)
      rake import:availabilities (runs clinician and patient availabilities)
      rake import:insurance (runs insurance_policies and insurance_coverages)
      
      Features
      --------
      - Idempotent: Safe to run multiple times
      - Error handling: Continues on errors, reports at end
      - Progress tracking: Shows progress dots and summary
      - Validation: Post-import validation of relationships
      
      CSV File Locations
      ------------------
      All CSV files are expected in: ../../devdocs/
      
      Required Files:
        - organizations.csv
        - contracts.csv
        - org_contracts.csv
        - credentialed_insurances.csv
        - therapists.csv
        - clinician_credentialed_insurances.csv
        - documents.csv
        - patients_and_guardians_anonymized.csv
        - kinships.csv
        - memberships.csv
        - referrals.csv
        - referral_members.csv
        - clinician_availabilities.csv
        - patient_availabilities.csv
        - insurance_policies.csv
        - insurance_coverages.csv
        - questionnaires.csv
      
      Import Order Dependencies
      --------------------------
      1. Organizations, Contracts, Credentialed Insurances, Therapists, Documents
         (no dependencies)
      
      2. Patients and Guardians
         (no dependencies, but should come before relationships)
      
      3. Kinships, Memberships
         (depends on: Parents, Students, Organizations)
      
      4. Referrals, Referral Members
         (depends on: Organizations, Contracts, Parents, Students)
      
      5. Availability Windows
         (depends on: Therapists, Parents, Students)
      
      6. Insurance Policies, Insurance Coverages
         (depends on: Parents, Students)
      
      7. Questionnaires
         (depends on: Students, Parents)
      
      Troubleshooting
      ---------------
      - If an import fails, check the error messages for specific row issues
      - Verify CSV files exist in ../../devdocs/ directory
      - Ensure database migrations have been run
      - Check that required foreign key records exist before importing dependent data
      - Run individual import tasks to isolate issues
      
      For more information, see: apps/api/lib/importers/README.md
    HELP
  end
end

