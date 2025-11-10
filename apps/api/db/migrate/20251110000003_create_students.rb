class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students, id: :uuid do |t|
      t.references :parent, null: false, foreign_key: true, type: :uuid
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.date :date_of_birth, null: false
      t.string :grade
      t.string :school
      t.string :language, null: false, default: 'en'

      t.timestamps
    end

    add_index :students, :date_of_birth
  end
end

