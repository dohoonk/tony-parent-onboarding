class AddQuestionnaireIdToScreenerResponses < ActiveRecord::Migration[8.0]
  def change
    add_column :screener_responses, :questionnaire_id, :uuid
    add_foreign_key :screener_responses, :questionnaires, column: :questionnaire_id, type: :uuid
    add_index :screener_responses, :questionnaire_id
  end
end

