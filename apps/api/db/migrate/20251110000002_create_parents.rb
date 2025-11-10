class CreateParents < ActiveRecord::Migration[8.0]
  def change
    create_table :parents, id: :uuid do |t|
      t.string :email, null: false
      t.string :phone
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :auth_provider, null: false, default: 'magic_link'

      t.timestamps
    end

    add_index :parents, :email, unique: true
    add_index :parents, :created_at
  end
end

