class CreateAppointments < ActiveRecord::Migration[8.0]
  def change
    create_enum :appointment_status, %w[scheduled confirmed completed cancelled no_show]

    create_table :appointments, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid
      t.references :student, null: false, foreign_key: true, type: :uuid
      t.uuid :therapist_id, null: false
      t.timestamp :scheduled_at, null: false
      t.integer :duration_minutes, null: false, default: 50
      t.enum :status, enum_type: 'appointment_status', default: 'scheduled', null: false
      t.text :notes

      t.timestamps
    end

    add_index :appointments, :therapist_id
    add_index :appointments, :scheduled_at
    add_index :appointments, :status
  end
end

