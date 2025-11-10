class CreateContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :contracts, id: :uuid do |t|
      # Contract dates
      t.date :effective_date, null: false
      t.date :end_date
      
      # Services offered under this contract (array)
      t.text :services, array: true, default: []
      
      # Contract terms and conditions (JSONB for flexibility)
      t.jsonb :terms, default: {}
      
      # Contract document URL
      t.string :contract_url
      
      t.timestamps
    end

    # Indexes
    add_index :contracts, :effective_date
    add_index :contracts, :end_date
    add_index :contracts, :created_at
    
    # GIN indexes for array and JSONB columns
    add_index :contracts, :services, using: :gin
    add_index :contracts, :terms, using: :gin
    
    # Composite index for date range queries
    add_index :contracts, [:effective_date, :end_date]
  end
end

