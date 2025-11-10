class CreateCostEstimates < ActiveRecord::Migration[8.0]
  def change
    create_table :cost_estimates, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.integer :min_cost_cents, null: false
      t.integer :max_cost_cents, null: false
      t.string :basis

      t.timestamp :created_at, null: false
    end
  end
end

