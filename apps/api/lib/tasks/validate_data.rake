namespace :validate do
  desc "Validate all imported data for integrity"
  task data: :environment do
    validator = Validators::DataIntegrityValidator.new
    validator.validate_all
    
    # Exit with error code if validation failed
    if validator.errors.any?
      exit 1
    end
  end

  desc "Validate specific model data"
  task :model, [:model_name] => :environment do |t, args|
    model_name = args[:model_name]
    unless model_name
      puts "Usage: rake validate:model[ModelName]"
      puts "Example: rake validate:model[Therapist]"
      exit 1
    end

    validator = Validators::DataIntegrityValidator.new
    
    case model_name.downcase
    when 'therapist', 'therapists'
      validator.send(:validate_therapists)
    when 'organization', 'organizations'
      validator.send(:validate_organizations)
    when 'contract', 'contracts'
      validator.send(:validate_contracts)
    when 'credentialed_insurance', 'credentialed_insurances'
      validator.send(:validate_credentialed_insurances)
    when 'clinician_credentialed_insurance', 'clinician_credentialed_insurances'
      validator.send(:validate_clinician_credentialed_insurances)
    when 'parent', 'parents'
      validator.send(:validate_parents)
    when 'student', 'students'
      validator.send(:validate_students)
    when 'referral', 'referrals'
      validator.send(:validate_referrals)
    when 'referral_member', 'referral_members'
      validator.send(:validate_referral_members)
    when 'kinship', 'kinships'
      validator.send(:validate_kinships)
    when 'membership', 'memberships'
      validator.send(:validate_memberships)
    when 'availability_window', 'availability_windows'
      validator.send(:validate_availability_windows)
    when 'appointment', 'appointments'
      validator.send(:validate_appointments)
    when 'insurance_policy', 'insurance_policies'
      validator.send(:validate_insurance_policies)
    when 'document', 'documents'
      validator.send(:validate_documents)
    when 'questionnaire', 'questionnaires'
      validator.send(:validate_questionnaires)
    else
      puts "Unknown model: #{model_name}"
      puts "Available models: Therapist, Organization, Contract, CredentialedInsurance, ClinicianCredentialedInsurance, Parent, Student, Referral, ReferralMember, Kinship, Membership, AvailabilityWindow, Appointment, InsurancePolicy, Document, Questionnaire"
      exit 1
    end

    validator.print_summary
    
    if validator.errors.any?
      exit 1
    end
  end
end

