class CreateMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :memberships, id: :uuid do |t|
      # Polymorphic user association (can be Parent or Student)
      t.uuid :user_id, null: false
      t.string :user_type, null: false # 'Parent' or 'Student'
      
      # Organization association
      t.uuid :organization_id, null: false
      
      # Additional data
      t.string :census_person_id
      t.jsonb :profile_data, default: {}
      t.jsonb :migration_details, default: {}

      t.timestamps
    end

    # Indexes
    add_index :memberships, [:user_id, :user_type]
    add_index :memberships, :organization_id
    add_index :memberships, :census_person_id
    add_index :memberships, :created_at
    
    # Composite indexes
    add_index :memberships, [:organization_id, :user_id, :user_type], unique: true, name: 'index_memberships_unique_user_org'
    add_index :memberships, [:user_id, :user_type, :organization_id]
    
    # GIN indexes for JSONB
    add_index :memberships, :profile_data, using: :gin
    add_index :memberships, :migration_details, using: :gin
    
    # Foreign key constraint
    add_foreign_key :memberships, :organizations, column: :organization_id, type: :uuid
  end
end

