module Importers
  class ClinicianCredentialedInsuranceImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/clinician_credentialed_insurances.csv')
      super(csv_path, ClinicianCredentialedInsurance)
    end

    protected

    def extract_id(row)
      # Use composite key for idempotency check
      "#{row['care_provider_profile_id']}-#{row['credentialed_insurance_id']}"
    end

    def record_exists?(composite_id)
      therapist_id, insurance_id = composite_id.split('-')
      ClinicianCredentialedInsurance.exists?(
        care_provider_profile_id: therapist_id,
        credentialed_insurance_id: insurance_id
      )
    end

    def build_attributes(row)
      therapist = find_record(Therapist, row['care_provider_profile_id'], required: true)
      insurance = find_record(CredentialedInsurance, row['credentialed_insurance_id'], required: true)
      
      {
        care_provider_profile_id: therapist.id,
        credentialed_insurance_id: insurance.id,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

