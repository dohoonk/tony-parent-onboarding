class AddPasswordDigestToParents < ActiveRecord::Migration[8.0]
  def change
    add_column :parents, :password_digest, :string
  end
end
