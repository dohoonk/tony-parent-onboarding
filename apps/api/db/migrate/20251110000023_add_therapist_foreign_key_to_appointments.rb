class AddTherapistForeignKeyToAppointments < ActiveRecord::Migration[8.0]
  def change
    # Add foreign key constraint from appointments.therapist_id to therapists.id
    add_foreign_key :appointments, :therapists, column: :therapist_id, type: :uuid
  end
end

