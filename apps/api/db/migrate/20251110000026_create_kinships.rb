class CreateKinships < ActiveRecord::Migration[8.0]
  def change
    create_table :kinships, id: :uuid do |t|
      # Polymorphic user associations (can be Parent or Student)
      t.uuid :user_0_id, null: false
      t.string :user_0_type, null: false # 'Parent' or 'Student'
      t.uuid :user_1_id, null: false
      t.string :user_1_type, null: false # 'Parent' or 'Student'
      
      # Relationship information
      t.integer :kind, null: false # Relationship type (1 = parent-child, etc.)
      t.string :user_0_label # Label for user_0 in this relationship
      t.string :user_1_label # Label for user_1 in this relationship
      t.boolean :guardian_can_be_contacted, default: false
      
      # Additional data
      t.jsonb :migration_details, default: {}

      t.timestamps
    end

    # Indexes
    add_index :kinships, [:user_0_id, :user_0_type]
    add_index :kinships, [:user_1_id, :user_1_type]
    add_index :kinships, :kind
    add_index :kinships, :guardian_can_be_contacted
    add_index :kinships, :created_at
    
    # Composite indexes
    add_index :kinships, [:user_0_id, :user_0_type, :user_1_id, :user_1_type], unique: true, name: 'index_kinships_unique_relationship'
    add_index :kinships, [:kind, :guardian_can_be_contacted]
    
    # GIN index for JSONB
    add_index :kinships, :migration_details, using: :gin
  end
end

