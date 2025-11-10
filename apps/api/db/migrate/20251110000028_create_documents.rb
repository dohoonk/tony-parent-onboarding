class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents, id: :uuid do |t|
      t.integer :version, null: false
      t.string :label, null: false # e.g., "privacy_policy", "informed_consent"
      t.text :checkboxes # JSON string or text for checkbox data
      t.date :version_date
      
      # Multi-language support (JSONB)
      t.jsonb :urls, default: {} # e.g., {"eng": "url", "spa": "url"}
      t.jsonb :names, default: {} # e.g., {"eng": "Privacy Policy", "spa": "Política de Privacidad"}

      t.timestamps
    end

    # Indexes
    add_index :documents, :label
    add_index :documents, :version
    add_index :documents, :version_date
    add_index :documents, :created_at
    
    # Composite indexes
    add_index :documents, [:label, :version], unique: true, name: 'index_documents_unique_label_version'
    
    # GIN indexes for JSONB
    add_index :documents, :urls, using: :gin
    add_index :documents, :names, using: :gin
  end
end

