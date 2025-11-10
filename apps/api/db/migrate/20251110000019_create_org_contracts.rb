class CreateOrgContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :org_contracts, id: :uuid do |t|
      # Foreign keys
      t.uuid :organization_id, null: false
      t.uuid :contract_id, null: false
      
      t.timestamps
    end

    # Indexes
    add_index :org_contracts, :organization_id
    add_index :org_contracts, :contract_id
    add_index :org_contracts, [:organization_id, :contract_id], unique: true
    add_index :org_contracts, :created_at
    
    # Foreign keys
    add_foreign_key :org_contracts, :organizations, column: :organization_id
    add_foreign_key :org_contracts, :contracts, column: :contract_id
  end
end

