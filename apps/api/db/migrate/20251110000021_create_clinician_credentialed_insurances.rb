class CreateClinicianCredentialedInsurances < ActiveRecord::Migration[8.0]
  def change
    create_table :clinician_credentialed_insurances, id: :uuid do |t|
      # Foreign keys
      t.uuid :care_provider_profile_id, null: false # This is therapist_id
      t.uuid :credentialed_insurance_id, null: false
      
      t.timestamps
    end

    # Indexes
    add_index :clinician_credentialed_insurances, :care_provider_profile_id, name: 'index_clinician_cred_ins_on_therapist_id'
    add_index :clinician_credentialed_insurances, :credentialed_insurance_id
    add_index :clinician_credentialed_insurances, [:care_provider_profile_id, :credentialed_insurance_id], unique: true, name: 'index_clinician_cred_ins_on_therapist_and_insurance'
    add_index :clinician_credentialed_insurances, :created_at
    
    # Foreign keys
    add_foreign_key :clinician_credentialed_insurances, :therapists, column: :care_provider_profile_id
    add_foreign_key :clinician_credentialed_insurances, :credentialed_insurances, column: :credentialed_insurance_id
  end
end

