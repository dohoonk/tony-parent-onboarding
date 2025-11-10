class CreateQuestionnaires < ActiveRecord::Migration[8.0]
  def change
    create_table :questionnaires, id: :uuid do |t|
      # Subject (student) and respondent (parent) associations
      t.uuid :subject_id, null: false # Student ID
      t.uuid :respondent_id, null: false # Parent ID
      
      # Questionnaire data
      t.integer :score, default: 0
      t.datetime :started_at
      t.datetime :completed_at
      t.jsonb :question_answers, default: {}
      t.integer :questionnaire_type, null: false # Questionnaire type (maps to screener key)
      t.string :language_of_completion, default: 'eng'
      t.string :census_person_id

      t.timestamps
    end

    # Foreign keys
    add_foreign_key :questionnaires, :students, column: :subject_id, type: :uuid
    add_foreign_key :questionnaires, :parents, column: :respondent_id, type: :uuid

    # Indexes
    add_index :questionnaires, :subject_id
    add_index :questionnaires, :respondent_id
    add_index :questionnaires, :questionnaire_type
    add_index :questionnaires, :score
    add_index :questionnaires, :completed_at
    add_index :questionnaires, :started_at
    add_index :questionnaires, :language_of_completion
    add_index :questionnaires, :created_at
    
    # Composite indexes
    add_index :questionnaires, [:subject_id, :questionnaire_type]
    add_index :questionnaires, [:respondent_id, :completed_at]
    
    # GIN index for JSONB
    add_index :questionnaires, :question_answers, using: :gin
  end
end

