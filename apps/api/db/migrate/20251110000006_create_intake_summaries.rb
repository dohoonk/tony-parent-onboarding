class CreateIntakeSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :intake_summaries, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.jsonb :concerns_json
      t.jsonb :goals_json
      t.jsonb :risk_flags_json
      t.text :summary_text

      t.timestamp :created_at, null: false
    end
  end
end

