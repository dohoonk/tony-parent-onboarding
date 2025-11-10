class AddFieldsToParents < ActiveRecord::Migration[8.0]
  def change
    add_column :parents, :preferred_name, :string
    add_column :parents, :middle_name, :string
    add_column :parents, :title, :string
    add_column :parents, :preferred_language, :string, default: 'eng'
    add_column :parents, :preferred_pronoun, :string
    add_column :parents, :legal_gender, :string
    add_column :parents, :birthdate, :date
    add_column :parents, :healthie_id, :string
    add_column :parents, :account_status, :string
    add_column :parents, :system_labels, :text, array: true, default: []
    add_column :parents, :address, :jsonb, default: {}
    add_column :parents, :profile_data, :jsonb, default: {}
    add_column :parents, :migration_details, :jsonb, default: {}
    add_column :parents, :supabase_metadata, :jsonb, default: {}

    # Indexes for commonly queried fields
    add_index :parents, :healthie_id
    add_index :parents, :account_status
    add_index :parents, :preferred_language
    add_index :parents, :birthdate

    # GIN indexes for array and JSONB fields
    add_index :parents, :system_labels, using: :gin
    add_index :parents, :address, using: :gin
    add_index :parents, :profile_data, using: :gin
    add_index :parents, :migration_details, using: :gin
    add_index :parents, :supabase_metadata, using: :gin
  end
end
