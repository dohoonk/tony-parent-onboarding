class CreateOnboardingSessions < ActiveRecord::Migration[8.0]
  def change
    create_enum :onboarding_status, %w[draft active completed abandoned]

    create_table :onboarding_sessions, id: :uuid do |t|
      t.references :parent, null: false, foreign_key: true, type: :uuid
      t.references :student, null: false, foreign_key: true, type: :uuid
      t.enum :status, enum_type: 'onboarding_status', default: 'draft', null: false
      t.integer :current_step, null: false, default: 1
      t.integer :eta_seconds
      t.timestamp :completed_at

      t.timestamps
    end

    add_index :onboarding_sessions, :status
  end
end

