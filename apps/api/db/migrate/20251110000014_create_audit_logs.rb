class CreateAuditLogs < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_logs, id: :uuid do |t|
      t.uuid :actor_id
      t.string :actor_type
      t.string :action, null: false
      t.string :entity_type, null: false
      t.uuid :entity_id, null: false
      t.jsonb :before_json
      t.jsonb :after_json
      t.string :ip_address
      t.text :user_agent

      t.timestamp :created_at, null: false
    end

    add_index :audit_logs, :actor_id
    add_index :audit_logs, [:entity_type, :entity_id]
    add_index :audit_logs, :created_at
  end
end

