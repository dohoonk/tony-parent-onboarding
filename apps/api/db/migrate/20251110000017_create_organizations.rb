class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    # Create enum for organization kind
    create_enum :organization_kind, ["district", "school"]

    create_table :organizations, id: :uuid do |t|
      # Self-referential parent relationship (districts have schools)
      t.uuid :parent_organization_id
      
      # Organization type
      t.enum :kind, enum_type: :organization_kind, null: false
      
      # Basic Information
      t.string :slug, null: false
      t.string :name, null: false
      t.string :internal_name
      t.string :tzdb # Timezone database identifier (e.g., "America/Los_Angeles")
      
      # External References
      t.uuid :market_id
      
      # Configuration and Metadata
      t.jsonb :config, default: {}
      t.timestamp :enabled_at
      
      t.timestamps
    end

    # Indexes
    add_index :organizations, :parent_organization_id
    add_index :organizations, :kind
    add_index :organizations, :slug, unique: true
    add_index :organizations, :market_id
    add_index :organizations, :enabled_at
    add_index :organizations, :created_at
    
    # Composite indexes for common queries
    add_index :organizations, [:kind, :parent_organization_id]
    add_index :organizations, [:parent_organization_id, :enabled_at]
    
    # GIN index for JSONB config
    add_index :organizations, :config, using: :gin
    
    # Foreign key for self-referential relationship
    add_foreign_key :organizations, :organizations, column: :parent_organization_id
  end
end

