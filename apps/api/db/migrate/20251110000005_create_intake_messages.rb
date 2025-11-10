class CreateIntakeMessages < ActiveRecord::Migration[8.0]
  def change
    create_enum :message_role, %w[user assistant system]

    create_table :intake_messages, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid
      t.enum :role, enum_type: 'message_role', null: false
      t.text :content, null: false
      t.text :de_identified_content

      t.timestamp :created_at, null: false
    end

    add_index :intake_messages, :created_at
  end
end

