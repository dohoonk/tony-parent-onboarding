class AddRoleToParents < ActiveRecord::Migration[8.0]
  def change
    add_column :parents, :role, :string, default: 'parent', null: false
    add_index :parents, :role
  end
end
