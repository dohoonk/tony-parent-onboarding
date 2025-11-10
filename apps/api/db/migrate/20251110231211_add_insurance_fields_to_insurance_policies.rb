class AddInsuranceFieldsToInsurancePolicies < ActiveRecord::Migration[8.0]
  def change
    # Card image URLs
    add_column :insurance_policies, :front_card_url, :string
    add_column :insurance_policies, :back_card_url, :string

    # Group ID (different from group_number)
    add_column :insurance_policies, :group_id, :string

    # Plan holder information (PHI - should be encrypted)
    add_column :insurance_policies, :plan_holder_first_name, :string
    add_column :insurance_policies, :plan_holder_last_name, :string
    add_column :insurance_policies, :plan_holder_dob, :date
    add_column :insurance_policies, :plan_holder_country, :string, default: 'US'
    add_column :insurance_policies, :plan_holder_state, :string
    add_column :insurance_policies, :plan_holder_city, :string
    add_column :insurance_policies, :plan_holder_street_address, :string
    add_column :insurance_policies, :plan_holder_zip_code, :string
    add_column :insurance_policies, :plan_holder_legal_gender, :string

    # Insurance company information
    add_column :insurance_policies, :insurance_company_name, :string

    # Policy metadata
    add_column :insurance_policies, :kind, :integer, default: 0
    add_column :insurance_policies, :level, :integer, default: 0
    add_column :insurance_policies, :eligibility, :integer, default: 0
    add_column :insurance_policies, :genesis, :integer, default: 0

    # System labels (array)
    add_column :insurance_policies, :system_labels, :text, array: true, default: []

    # OpenPM integration fields
    add_column :insurance_policies, :openpm_insurance_organization_id, :string
    add_column :insurance_policies, :openpm_coverage_id, :string
    add_column :insurance_policies, :openpm_insurance_organization_name, :string

    # Flexible data fields (JSONB)
    add_column :insurance_policies, :migration_details, :jsonb, default: {}
    add_column :insurance_policies, :profile_data, :jsonb, default: {}

    # Foreign keys
    add_reference :insurance_policies, :user, type: :uuid, polymorphic: true, null: true, index: true
    add_reference :insurance_policies, :created_by, type: :uuid, null: true, index: true
    add_foreign_key :insurance_policies, :parents, column: :created_by_id, type: :uuid

    # Indexes for common queries
    add_index :insurance_policies, :group_id
    add_index :insurance_policies, :insurance_company_name
    add_index :insurance_policies, :kind
    add_index :insurance_policies, :level
    add_index :insurance_policies, :eligibility
    add_index :insurance_policies, :plan_holder_state
    add_index :insurance_policies, :plan_holder_zip_code
    add_index :insurance_policies, :openpm_insurance_organization_id
    add_index :insurance_policies, :openpm_coverage_id
    add_index :insurance_policies, :system_labels, using: :gin
    add_index :insurance_policies, :migration_details, using: :gin
    add_index :insurance_policies, :profile_data, using: :gin
  end
end
