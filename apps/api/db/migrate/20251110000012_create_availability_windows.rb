class CreateAvailabilityWindows < ActiveRecord::Migration[8.0]
  def change
    create_table :availability_windows, id: :uuid do |t|
      t.string :owner_type, null: false
      t.uuid :owner_id, null: false
      t.string :rrule
      t.date :start_date, null: false
      t.date :end_date

      t.timestamps
    end

    add_index :availability_windows, [:owner_type, :owner_id]
    add_index :availability_windows, :start_date
  end
end

