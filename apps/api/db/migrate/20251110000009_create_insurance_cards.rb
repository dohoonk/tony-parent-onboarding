class CreateInsuranceCards < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_cards, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid
      t.string :front_image_url, null: false
      t.string :back_image_url
      t.jsonb :ocr_json
      t.jsonb :confidence_json

      t.timestamp :created_at, null: false
    end
  end
end

