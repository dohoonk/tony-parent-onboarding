class CreateTherapists < ActiveRecord::Migration[8.0]
  def change
    create_table :therapists, id: :uuid do |t|
      # External IDs
      t.string :healthie_id
      
      # Basic Information
      t.string :email
      t.string :phone
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :preferred_name
      t.string :preferred_pronoun
      t.string :title
      t.date :birthdate
      t.string :preferred_language, default: 'en'
      
      # Demographics
      t.string :legal_gender
      t.string :standardized_gender
      t.string :self_gender
      t.string :gender_identity
      t.string :ethnicity
      t.text :ethnicity_and_demographics, array: true, default: []
      t.string :primary_ethnicity
      t.string :primary_ethnicity_code
      t.string :primary_race
      t.string :primary_race_code
      t.text :religions, array: true, default: []
      t.string :standardized_sexual_orientation
      t.string :self_sexual_orientation
      t.string :sexual_orientation
      t.string :sexual_orientation_code
      
      # Professional Information
      t.string :npi_number
      t.text :licenses, array: true, default: []
      t.text :licensed_states, array: true, default: []
      t.string :primary_state
      t.text :states_active, array: true, default: []
      t.text :specialties, array: true, default: []
      t.text :modalities, array: true, default: []
      t.text :care_languages, array: true, default: []
      t.string :employment_type
      t.string :clinical_role
      t.string :care_provider_role
      t.string :care_provider_status
      t.boolean :clinical_associate, default: false
      t.boolean :is_super_admin, default: false
      
      # Bio and Profile
      t.text :bio
      t.jsonb :profile_data, default: {}
      
      # Supervision
      t.uuid :supervisor_id
      t.uuid :associate_supervisor_id
      
      # Capacity Management
      t.integer :capacity_total, default: 0
      t.integer :capacity_filled, default: 0
      t.integer :capacity_available, default: 0
      t.integer :capacity_total_daybreak, default: 0
      t.integer :capacity_filled_daybreak, default: 0
      t.integer :capacity_available_daybreak, default: 0
      t.integer :capacity_total_kaiser, default: 0
      t.integer :capacity_filled_kaiser, default: 0
      t.integer :capacity_available_kaiser, default: 0
      
      # Status and Metadata
      t.string :account_status
      t.text :system_labels, array: true, default: []
      t.boolean :active, default: true
      
      t.timestamps
    end

    # Indexes
    add_index :therapists, :email
    add_index :therapists, :healthie_id
    add_index :therapists, :supervisor_id
    add_index :therapists, :employment_type
    add_index :therapists, :clinical_role
    add_index :therapists, :primary_state
    add_index :therapists, :npi_number
    add_index :therapists, :active
    add_index :therapists, :created_at
    
    # Composite indexes for common queries
    add_index :therapists, [:employment_type, :active]
    add_index :therapists, [:primary_state, :active]
    
    # GIN indexes for array columns (for array containment queries)
    add_index :therapists, :specialties, using: :gin
    add_index :therapists, :licensed_states, using: :gin
    add_index :therapists, :care_languages, using: :gin
    
    # GIN index for JSONB
    add_index :therapists, :profile_data, using: :gin
    
    # Foreign key for self-referential supervisor relationship
    add_foreign_key :therapists, :therapists, column: :supervisor_id
    add_foreign_key :therapists, :therapists, column: :associate_supervisor_id
  end
end

