module Validators
  class DataIntegrityValidator
    attr_reader :errors, :warnings, :stats

    def initialize
      @errors = []
      @warnings = []
      @stats = {
        total_records: 0,
        valid_records: 0,
        invalid_records: 0,
        checked_relationships: 0,
        broken_relationships: 0
      }
    end

    def validate_all
      puts "=" * 80
      puts "DATA INTEGRITY VALIDATION"
      puts "=" * 80
      puts "\n"

      validate_therapists
      validate_organizations
      validate_contracts
      validate_credentialed_insurances
      validate_clinician_credentialed_insurances
      validate_parents
      validate_students
      validate_referrals
      validate_referral_members
      validate_kinships
      validate_memberships
      validate_availability_windows
      validate_appointments
      validate_insurance_policies
      validate_documents
      validate_questionnaires

      print_summary
    end

    private

    def validate_therapists
      puts "Validating Therapists..."
      Therapist.find_each do |therapist|
        @stats[:total_records] += 1
        valid = true

        # Validate supervisor relationships
        if therapist.supervisor_id.present?
          unless Therapist.exists?(id: therapist.supervisor_id)
            add_error("Therapist #{therapist.id}", "supervisor_id #{therapist.supervisor_id} not found")
            valid = false
          end
        end

        # Validate required fields
        if therapist.email.blank?
          add_error("Therapist #{therapist.id}", "email is required")
          valid = false
        end

        # Validate arrays are arrays
        unless therapist.specialties.is_a?(Array)
          add_error("Therapist #{therapist.id}", "specialties must be an array")
          valid = false
        end

        # Validate JSONB fields
        unless therapist.profile_data.is_a?(Hash)
          add_error("Therapist #{therapist.id}", "profile_data must be a hash")
          valid = false
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Therapist.count} therapists\n"
    end

    def validate_organizations
      puts "Validating Organizations..."
      Organization.find_each do |org|
        @stats[:total_records] += 1
        valid = true

        # Validate parent organization
        if org.parent_organization_id.present?
          unless Organization.exists?(id: org.parent_organization_id)
            add_error("Organization #{org.id}", "parent_organization_id #{org.parent_organization_id} not found")
            valid = false
          end
        end

        # Validate kind enum
        unless %w[district school].include?(org.kind)
          add_error("Organization #{org.id}", "kind must be 'district' or 'school'")
          valid = false
        end

        # Validate school has parent
        if org.kind == 'school' && org.parent_organization_id.blank?
          add_warning("Organization #{org.id}", "school should have a parent_organization_id")
        end

        # Validate JSONB
        unless org.config.is_a?(Hash)
          add_error("Organization #{org.id}", "config must be a hash")
          valid = false
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Organization.count} organizations\n"
    end

    def validate_contracts
      puts "Validating Contracts..."
      Contract.find_each do |contract|
        @stats[:total_records] += 1
        valid = true

        # Validate date range
        if contract.effective_date.present? && contract.end_date.present?
          if contract.effective_date > contract.end_date
            add_error("Contract #{contract.id}", "effective_date must be before end_date")
            valid = false
          end
        end

        # Validate arrays
        unless contract.services.is_a?(Array)
          add_error("Contract #{contract.id}", "services must be an array")
          valid = false
        end

        # Validate JSONB
        unless contract.terms.is_a?(Hash)
          add_error("Contract #{contract.id}", "terms must be a hash")
          valid = false
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Contract.count} contracts\n"
    end

    def validate_credentialed_insurances
      puts "Validating Credentialed Insurances..."
      CredentialedInsurance.find_each do |insurance|
        @stats[:total_records] += 1
        valid = true

        # Validate parent relationship
        if insurance.parent_credentialed_insurance_id.present?
          unless CredentialedInsurance.exists?(id: insurance.parent_credentialed_insurance_id)
            add_error("CredentialedInsurance #{insurance.id}", "parent_credentialed_insurance_id not found")
            valid = false
          end
        end

        # Validate network_status
        unless [0, 1].include?(insurance.network_status)
          add_error("CredentialedInsurance #{insurance.id}", "network_status must be 0 or 1")
          valid = false
        end

        # Validate arrays
        unless insurance.legacy_names.is_a?(Array)
          add_error("CredentialedInsurance #{insurance.id}", "legacy_names must be an array")
          valid = false
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{CredentialedInsurance.count} credentialed insurances\n"
    end

    def validate_clinician_credentialed_insurances
      puts "Validating Clinician Credentialed Insurances..."
      @stats[:checked_relationships] += ClinicianCredentialedInsurance.count
      
      ClinicianCredentialedInsurance.find_each do |cci|
        @stats[:total_records] += 1
        valid = true

        # Validate therapist exists
        unless Therapist.exists?(id: cci.care_provider_profile_id)
          add_error("ClinicianCredentialedInsurance #{cci.id}", "therapist #{cci.care_provider_profile_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate insurance exists
        unless CredentialedInsurance.exists?(id: cci.credentialed_insurance_id)
          add_error("ClinicianCredentialedInsurance #{cci.id}", "credentialed_insurance #{cci.credentialed_insurance_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{ClinicianCredentialedInsurance.count} clinician credentialed insurances\n"
    end

    def validate_parents
      puts "Validating Parents..."
      Parent.find_each do |parent|
        @stats[:total_records] += 1
        valid = true

        # Validate required fields
        if parent.email.blank?
          add_error("Parent #{parent.id}", "email is required")
          valid = false
        end

        # Validate arrays
        unless parent.system_labels.is_a?(Array)
          add_error("Parent #{parent.id}", "system_labels must be an array")
          valid = false
        end

        # Validate JSONB fields
        %w[address profile_data migration_details supabase_metadata].each do |field|
          value = parent.send(field)
          unless value.is_a?(Hash) || value.blank?
            add_error("Parent #{parent.id}", "#{field} must be a hash")
            valid = false
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Parent.count} parents\n"
    end

    def validate_students
      puts "Validating Students..."
      Student.find_each do |student|
        @stats[:total_records] += 1
        valid = true

        # Validate parent exists
        unless Parent.exists?(id: student.parent_id)
          add_error("Student #{student.id}", "parent #{student.parent_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate required fields
        if student.date_of_birth.blank?
          add_error("Student #{student.id}", "date_of_birth is required")
          valid = false
        end

        # Validate arrays
        unless student.system_labels.is_a?(Array)
          add_error("Student #{student.id}", "system_labels must be an array")
          valid = false
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Student.count} students\n"
    end

    def validate_referrals
      puts "Validating Referrals..."
      Referral.find_each do |referral|
        @stats[:total_records] += 1
        valid = true

        # Validate submitter exists
        unless Parent.exists?(id: referral.submitter_id)
          add_error("Referral #{referral.id}", "submitter #{referral.submitter_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate organization exists
        unless Organization.exists?(id: referral.organization_id)
          add_error("Referral #{referral.id}", "organization #{referral.organization_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate contract if present
        if referral.contract_id.present?
          unless Contract.exists?(id: referral.contract_id)
            add_error("Referral #{referral.id}", "contract #{referral.contract_id} not found")
            valid = false
            @stats[:broken_relationships] += 1
          end
        end

        # Validate therapist if present
        if referral.care_provider_id.present?
          unless Therapist.exists?(id: referral.care_provider_id)
            add_error("Referral #{referral.id}", "therapist #{referral.care_provider_id} not found")
            valid = false
            @stats[:broken_relationships] += 1
          end
        end

        # Validate arrays
        %w[allowed_coverage care_provider_requirements system_labels].each do |field|
          value = referral.send(field)
          unless value.is_a?(Array)
            add_error("Referral #{referral.id}", "#{field} must be an array")
            valid = false
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Referral.count} referrals\n"
    end

    def validate_referral_members
      puts "Validating Referral Members..."
      @stats[:checked_relationships] += ReferralMember.count
      
      ReferralMember.find_each do |member|
        @stats[:total_records] += 1
        valid = true

        # Validate referral exists
        unless Referral.exists?(id: member.referral_id)
          add_error("ReferralMember #{member.id}", "referral #{member.referral_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate user exists
        user_class = member.user_type.constantize rescue nil
        if user_class.nil?
          add_error("ReferralMember #{member.id}", "invalid user_type: #{member.user_type}")
          valid = false
        elsif !user_class.exists?(id: member.user_id)
          add_error("ReferralMember #{member.id}", "#{member.user_type} #{member.user_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{ReferralMember.count} referral members\n"
    end

    def validate_kinships
      puts "Validating Kinships..."
      @stats[:checked_relationships] += Kinship.count
      
      Kinship.find_each do |kinship|
        @stats[:total_records] += 1
        valid = true

        # Validate user_0 exists
        user_0_class = kinship.user_0_type.constantize rescue nil
        if user_0_class.nil?
          add_error("Kinship #{kinship.id}", "invalid user_0_type: #{kinship.user_0_type}")
          valid = false
        elsif !user_0_class.exists?(id: kinship.user_0_id)
          add_error("Kinship #{kinship.id}", "#{kinship.user_0_type} #{kinship.user_0_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate user_1 exists
        user_1_class = kinship.user_1_type.constantize rescue nil
        if user_1_class.nil?
          add_error("Kinship #{kinship.id}", "invalid user_1_type: #{kinship.user_1_type}")
          valid = false
        elsif !user_1_class.exists?(id: kinship.user_1_id)
          add_error("Kinship #{kinship.id}", "#{kinship.user_1_type} #{kinship.user_1_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate kind
        unless [0, 1, 2, 3].include?(kinship.kind)
          add_error("Kinship #{kinship.id}", "kind must be 0, 1, 2, or 3")
          valid = false
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Kinship.count} kinships\n"
    end

    def validate_memberships
      puts "Validating Memberships..."
      @stats[:checked_relationships] += Membership.count
      
      Membership.find_each do |membership|
        @stats[:total_records] += 1
        valid = true

        # Validate organization exists
        unless Organization.exists?(id: membership.organization_id)
          add_error("Membership #{membership.id}", "organization #{membership.organization_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate user exists
        user_class = membership.user_type.constantize rescue nil
        if user_class.nil?
          add_error("Membership #{membership.id}", "invalid user_type: #{membership.user_type}")
          valid = false
        elsif !user_class.exists?(id: membership.user_id)
          add_error("Membership #{membership.id}", "#{membership.user_type} #{membership.user_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Membership.count} memberships\n"
    end

    def validate_availability_windows
      puts "Validating Availability Windows..."
      AvailabilityWindow.find_each do |window|
        @stats[:total_records] += 1
        valid = true

        # Validate owner exists (polymorphic)
        owner_class = window.owner_type.constantize rescue nil
        if owner_class.nil?
          add_error("AvailabilityWindow #{window.id}", "invalid owner_type: #{window.owner_type}")
          valid = false
        elsif !owner_class.exists?(id: window.owner_id)
          add_error("AvailabilityWindow #{window.id}", "#{window.owner_type} #{window.owner_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate owner_type is valid
        unless %w[Parent Therapist Student].include?(window.owner_type)
          add_error("AvailabilityWindow #{window.id}", "owner_type must be Parent, Therapist, or Student")
          valid = false
        end

        # Validate has either rrule or availability_json
        if window.rrule.blank? && window.availability_json.blank?
          add_error("AvailabilityWindow #{window.id}", "must have either rrule or availability_json")
          valid = false
        end

        # Validate JSONB fields
        if window.availability_json.present?
          unless window.availability_json.is_a?(Hash)
            add_error("AvailabilityWindow #{window.id}", "availability_json must be a hash")
            valid = false
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{AvailabilityWindow.count} availability windows\n"
    end

    def validate_appointments
      puts "Validating Appointments..."
      Appointment.find_each do |appointment|
        @stats[:total_records] += 1
        valid = true

        # Validate session exists
        unless OnboardingSession.exists?(id: appointment.onboarding_session_id)
          add_error("Appointment #{appointment.id}", "onboarding_session #{appointment.onboarding_session_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate therapist exists if present
        if appointment.therapist_id.present?
          unless Therapist.exists?(id: appointment.therapist_id)
            add_error("Appointment #{appointment.id}", "therapist #{appointment.therapist_id} not found")
            valid = false
            @stats[:broken_relationships] += 1
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Appointment.count} appointments\n"
    end

    def validate_insurance_policies
      puts "Validating Insurance Policies..."
      InsurancePolicy.find_each do |policy|
        @stats[:total_records] += 1
        valid = true

        # Validate session exists
        unless OnboardingSession.exists?(id: policy.onboarding_session_id)
          add_error("InsurancePolicy #{policy.id}", "onboarding_session #{policy.onboarding_session_id} not found")
          valid = false
          @stats[:broken_relationships] += 1
        end

        # Validate arrays
        unless policy.system_labels.is_a?(Array)
          add_error("InsurancePolicy #{policy.id}", "system_labels must be an array")
          valid = false
        end

        # Validate JSONB fields
        %w[migration_details profile_data].each do |field|
          value = policy.send(field)
          unless value.is_a?(Hash) || value.blank?
            add_error("InsurancePolicy #{policy.id}", "#{field} must be a hash")
            valid = false
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{InsurancePolicy.count} insurance policies\n"
    end

    def validate_documents
      puts "Validating Documents..."
      Document.find_each do |document|
        @stats[:total_records] += 1
        valid = true

        # Validate JSONB fields
        %w[migration_details profile_data].each do |field|
          value = document.send(field)
          unless value.is_a?(Hash) || value.blank?
            add_error("Document #{document.id}", "#{field} must be a hash")
            valid = false
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Document.count} documents\n"
    end

    def validate_questionnaires
      puts "Validating Questionnaires..."
      Questionnaire.find_each do |questionnaire|
        @stats[:total_records] += 1
        valid = true

        # Validate respondent exists if present
        if questionnaire.respondent_id.present?
          unless Parent.exists?(id: questionnaire.respondent_id)
            add_error("Questionnaire #{questionnaire.id}", "respondent #{questionnaire.respondent_id} not found")
            valid = false
            @stats[:broken_relationships] += 1
          end
        end

        # Validate subject exists if present
        if questionnaire.subject_id.present?
          unless Student.exists?(id: questionnaire.subject_id)
            add_error("Questionnaire #{questionnaire.id}", "subject #{questionnaire.subject_id} not found")
            valid = false
            @stats[:broken_relationships] += 1
          end
        end

        # Validate JSONB fields
        %w[responses metadata].each do |field|
          value = questionnaire.send(field)
          unless value.is_a?(Hash) || value.blank?
            add_error("Questionnaire #{questionnaire.id}", "#{field} must be a hash")
            valid = false
          end
        end

        if valid
          @stats[:valid_records] += 1
        else
          @stats[:invalid_records] += 1
        end
      end
      puts "  ✓ Validated #{Questionnaire.count} questionnaires\n"
    end

    def add_error(record, message)
      @errors << "#{record}: #{message}"
    end

    def add_warning(record, message)
      @warnings << "#{record}: #{message}"
    end

    def print_summary
      puts "\n" + "=" * 80
      puts "VALIDATION SUMMARY"
      puts "=" * 80
      puts "\nStatistics:"
      puts "  Total records checked: #{@stats[:total_records]}"
      puts "  Valid records: #{@stats[:valid_records]}"
      puts "  Invalid records: #{@stats[:invalid_records]}"
      puts "  Relationships checked: #{@stats[:checked_relationships]}"
      puts "  Broken relationships: #{@stats[:broken_relationships]}"
      
      if @errors.any?
        puts "\nErrors (#{@errors.count}):"
        @errors.first(20).each do |error|
          puts "  ✗ #{error}"
        end
        puts "  ... (#{@errors.count - 20} more errors)" if @errors.count > 20
      end

      if @warnings.any?
        puts "\nWarnings (#{@warnings.count}):"
        @warnings.first(10).each do |warning|
          puts "  ⚠ #{warning}"
        end
        puts "  ... (#{@warnings.count - 10} more warnings)" if @warnings.count > 10
      end

      if @errors.empty? && @warnings.empty?
        puts "\n✓ All validations passed!"
      else
        puts "\n✗ Validation found issues. Please review and fix."
      end
      puts "\n"
    end
  end
end

