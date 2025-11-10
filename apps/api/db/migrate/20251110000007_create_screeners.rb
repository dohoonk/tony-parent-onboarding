class CreateScreeners < ActiveRecord::Migration[8.0]
  def change
    create_table :screeners, id: :uuid do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.string :version, null: false
      t.jsonb :items_json, null: false

      t.timestamp :created_at, null: false
    end

    add_index :screeners, :key, unique: true
  end
end

