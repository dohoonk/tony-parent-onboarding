class CreateCredentialedInsurances < ActiveRecord::Migration[8.0]
  def change
    create_table :credentialed_insurances, id: :uuid do |t|
      # Self-referential parent relationship (for insurance hierarchies)
      t.uuid :parent_credentialed_insurance_id
      
      # Basic Information
      t.string :name, null: false
      t.string :country, default: 'US'
      t.string :state
      t.string :line_of_business
      t.text :legacy_names, array: true, default: []
      t.string :open_pm_name
      
      # Status and Configuration
      t.integer :network_status, default: 0
      t.boolean :associates_allowed, default: false
      t.string :legacy_id
      
      t.timestamps
    end

    # Indexes
    add_index :credentialed_insurances, :parent_credentialed_insurance_id
    add_index :credentialed_insurances, :name
    add_index :credentialed_insurances, [:country, :state]
    add_index :credentialed_insurances, :network_status
    add_index :credentialed_insurances, :created_at
    
    # Composite indexes for common queries
    add_index :credentialed_insurances, [:name, :state]
    add_index :credentialed_insurances, [:parent_credentialed_insurance_id, :network_status]
    
    # GIN index for array column
    add_index :credentialed_insurances, :legacy_names, using: :gin
    
    # Foreign key for self-referential relationship
    add_foreign_key :credentialed_insurances, :credentialed_insurances, column: :parent_credentialed_insurance_id
  end
end

