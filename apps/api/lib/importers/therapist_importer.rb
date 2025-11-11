module Importers
  class TherapistImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/clinicians_anonymized.csv')
      super(csv_path, Therapist)
    end

    protected

    def build_attributes(row)
      # Parse supervisor relationships (will be handled after import)
      supervisor_id = parse_uuid(row, 'supervisor_id')
      associate_supervisor_id = parse_uuid(row, 'associate_supervisor_id')
      supervisor_id = nil if supervisor_id.present? && !Therapist.exists?(id: supervisor_id)
      associate_supervisor_id = nil if associate_supervisor_id.present? && !Therapist.exists?(id: associate_supervisor_id)
      
      # Parse arrays
      specialties = parse_array_field(row, 'specialties', default: [])
      modalities = parse_array_field(row, 'modalities', default: [])
      licenses = parse_array_field(row, 'licenses', default: [])
      licensed_states = parse_array_field(row, 'licensed_states', default: [])
      care_languages = parse_array_field(row, 'care_languages', default: [])
      system_labels = parse_array_field(row, 'system_labels', default: [])
      ethnicity_and_demographics = parse_array_field(row, 'ethnicity_and_demographics', default: [])
      religions = parse_array_field(row, 'religions', default: [])
      
      # Parse JSONB fields
      profile_data = parse_json_field(row, 'profile_data', default: {})
      migration_details = parse_json_field(row, 'migration_details', default: {})
      
      employment_type = row['employment_type'].presence
      allowed_employment_types = ['W2 Hourly', '1099 Contractor', 'Full-time', 'Part-time', 'Contractor']
      employment_type = nil unless allowed_employment_types.include?(employment_type)

      clinical_role = row['clinical_role'].presence
      allowed_clinical_roles = ['Therapist', 'Clinician', 'Supervisor', 'Associate']
      clinical_role = nil unless allowed_clinical_roles.include?(clinical_role)

      {
        id: row['id'],
        healthie_id: row['healthie_id'].presence,
        email: row['email'],
        npi_number: row['npi_number'].presence,
        first_name: row['first_name'],
        middle_name: row['middle_name'].presence,
        last_name: row['last_name'],
        preferred_name: row['preferred_name'].presence,
        preferred_pronoun: row['preferred_pronoun'].presence,
        title: row['title'].presence,
        phone: row['phone'].presence,
        birthdate: parse_date(row, 'birthdate'),
        legal_gender: row['legal_gender'].presence,
        standardized_gender: row['standardized_gender'].presence,
        self_gender: row['self_gender'].presence,
        sexual_orientation: row['sexual_orientation'].presence,
        standardized_sexual_orientation: row['standardized_sexual_orientation'].presence,
        self_sexual_orientation: row['self_sexual_orientation'].presence,
        ethnicity: row['ethnicity'].presence,
        ethnicity_and_demographics: ethnicity_and_demographics,
        primary_ethnicity: row['primary_ethnicity'].presence,
        primary_ethnicity_code: row['primary_ethnicity_code'].presence,
        primary_race: row['primary_race'].presence,
        primary_race_code: row['primary_race_code'].presence,
        religions: religions,
        preferred_language: row['preferred_language'].presence,
        care_languages: care_languages,
        bio: row['bio'].presence,
        specialties: specialties,
        modalities: modalities,
        licenses: licenses,
        licensed_states: licensed_states,
        primary_state: row['primary_state'].presence,
        employment_type: employment_type,
        clinical_role: clinical_role,
        care_provider_status: row['care_provider_status'].presence,
        is_super_admin: parse_boolean(row, 'is_super_admin', default: false),
        supervisor_id: supervisor_id,
        associate_supervisor_id: associate_supervisor_id,
        capacity_total: parse_integer(row, 'capacity_total', default: 0),
        capacity_filled: parse_integer(row, 'capacity_filled', default: 0),
        capacity_available: parse_integer(row, 'capacity_available', default: 0),
        capacity_total_daybreak: parse_integer(row, 'capacity_total_daybreak', default: 0),
        capacity_filled_daybreak: parse_integer(row, 'capacity_filled_daybreak', default: 0),
        capacity_available_daybreak: parse_integer(row, 'capacity_available_daybreak', default: 0),
        capacity_total_kaiser: parse_integer(row, 'capacity_total_kaiser', default: 0),
        capacity_filled_kaiser: parse_integer(row, 'capacity_filled_kaiser', default: 0),
        capacity_available_kaiser: parse_integer(row, 'capacity_available_kaiser', default: 0),
        account_status: row['account_status'].presence,
        system_labels: system_labels,
        active: parse_boolean(row, 'active', default: true),
        profile_data: profile_data,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

