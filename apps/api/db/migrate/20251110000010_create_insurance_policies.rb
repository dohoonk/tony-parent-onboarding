class CreateInsurancePolicies < ActiveRecord::Migration[8.0]
  def change
    create_table :insurance_policies, id: :uuid do |t|
      t.references :onboarding_session, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :payer_name, null: false
      t.string :member_id, null: false
      t.string :group_number
      t.string :plan_type
      t.string :subscriber_name
      t.timestamp :verified_at

      t.timestamps
    end
  end
end

