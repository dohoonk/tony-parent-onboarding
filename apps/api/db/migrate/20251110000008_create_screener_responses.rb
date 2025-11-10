class CreateScreenerResponses < ActiveRecord::Migration[8.0]
  def change
    create_table :screener_responses, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid
      t.references :screener, null: false, foreign_key: true, type: :uuid
      t.jsonb :answers_json, null: false
      t.integer :score
      t.text :interpretation_text

      t.timestamp :created_at, null: false
    end
  end
end

