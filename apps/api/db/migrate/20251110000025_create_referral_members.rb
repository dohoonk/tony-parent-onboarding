class CreateReferralMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :referral_members, id: :uuid do |t|
      # Foreign keys
      t.uuid :referral_id, null: false
      t.uuid :user_id, null: false # Can be parent or student
      t.string :user_type, null: false # 'Parent' or 'Student' for polymorphic
      
      # Member information
      t.integer :role # 0 = student, 1 = parent/guardian, etc.
      t.jsonb :data, default: {} # Flexible JSONB for member-specific data

      t.timestamps
    end

    # Indexes
    add_index :referral_members, :referral_id
    add_index :referral_members, [:user_id, :user_type]
    add_index :referral_members, :role
    add_index :referral_members, :created_at
    
    # Composite index for unique constraint
    add_index :referral_members, [:referral_id, :user_id, :user_type], unique: true, name: 'index_referral_members_unique'
    
    # GIN index for JSONB
    add_index :referral_members, :data, using: :gin
    
    # Foreign key
    add_foreign_key :referral_members, :referrals, column: :referral_id
  end
end

