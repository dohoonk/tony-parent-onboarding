class CreateReferrals < ActiveRecord::Migration[8.0]
  def change
    create_table :referrals, id: :uuid do |t|
      # Foreign keys
      t.uuid :submitter_id, null: false # Parent who submitted the referral
      t.uuid :organization_id, null: false # Organization (school/district)
      t.uuid :contract_id, null: true # Contract associated with the referral
      t.uuid :intake_id, null: true # Link to intake/onboarding session
      t.uuid :care_provider_id, null: true # Assigned therapist/care provider
      
      # Basic information
      t.integer :service_kind # 1 = individual, 2 = group, etc.
      t.text :concerns # Why services are being requested
      t.jsonb :data, default: {} # Flexible JSONB for additional data
      
      # Contract and terms
      t.integer :terms_kind # 1 = sponsored, 2 = onsite, etc.
      t.integer :appointment_kind # 1 = virtual, 2 = in-person, etc.
      t.integer :planned_sessions
      t.integer :initial_scheduled_sessions
      
      # Coverage and payment
      t.boolean :collect_coverage, default: false
      t.text :allowed_coverage, array: true, default: [] # e.g., ["insurance", "self_pay"]
      t.integer :collection_rule # 0 = no collection, 1 = collect, etc.
      t.boolean :self_responsibility_required, default: false
      
      # Care provider requirements
      t.text :care_provider_requirements, array: true, default: []
      
      # Status timestamps
      t.timestamp :referred_at
      t.timestamp :ready_for_scheduling_at
      t.timestamp :scheduled_at
      t.timestamp :onboarding_completed_at
      t.timestamp :enrolled_at
      t.timestamp :disenrolled_at
      t.timestamp :request_rejected_at
      t.timestamp :excluded_at
      
      # Additional fields
      t.text :system_labels, array: true, default: []
      t.string :tzdb # Timezone database identifier
      t.text :notes
      t.string :disenrollment_category
      t.string :zendesk_ticket_id
      t.uuid :market_id # Market reference (if implemented)

      t.timestamps
    end

    # Indexes
    add_index :referrals, :submitter_id
    add_index :referrals, :organization_id
    add_index :referrals, :contract_id
    add_index :referrals, :intake_id
    add_index :referrals, :care_provider_id
    add_index :referrals, :service_kind
    add_index :referrals, :referred_at
    add_index :referrals, :scheduled_at
    add_index :referrals, :enrolled_at
    add_index :referrals, :created_at
    
    # Composite indexes
    add_index :referrals, [:organization_id, :referred_at]
    add_index :referrals, [:submitter_id, :created_at]
    
    # GIN indexes for arrays and JSONB
    add_index :referrals, :allowed_coverage, using: :gin
    add_index :referrals, :care_provider_requirements, using: :gin
    add_index :referrals, :system_labels, using: :gin
    add_index :referrals, :data, using: :gin
    
    # Foreign keys
    add_foreign_key :referrals, :parents, column: :submitter_id
    add_foreign_key :referrals, :organizations, column: :organization_id
    add_foreign_key :referrals, :contracts, column: :contract_id
    add_foreign_key :referrals, :therapists, column: :care_provider_id
  end
end

