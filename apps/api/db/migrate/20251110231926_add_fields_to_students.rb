class AddFieldsToStudents < ActiveRecord::Migration[8.0]
  def change
    add_column :students, :middle_name, :string
    add_column :students, :preferred_name, :string
    add_column :students, :legal_gender, :string
    add_column :students, :healthie_id, :string
    add_column :students, :account_status, :string
    add_column :students, :system_labels, :text, array: true, default: []
    add_column :students, :profile_data, :jsonb, default: {}
    add_column :students, :migration_details, :jsonb, default: {}
    add_column :students, :supabase_metadata, :jsonb, default: {}

    # Indexes for commonly queried fields
    add_index :students, :healthie_id
    add_index :students, :account_status
    add_index :students, :legal_gender

    # GIN indexes for array and JSONB fields
    add_index :students, :system_labels, using: :gin
    add_index :students, :profile_data, using: :gin
    add_index :students, :migration_details, using: :gin
    add_index :students, :supabase_metadata, using: :gin
  end
end
