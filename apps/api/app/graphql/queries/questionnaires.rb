module Queries
  class Questionnaires < BaseQuery
    type [Types::QuestionnaireType], null: false
    description "List questionnaires"

    argument :subject_id, ID, required: false, description: "Filter by subject (student) ID"
    argument :respondent_id, ID, required: false, description: "Filter by respondent (parent) ID"
    argument :questionnaire_type, Integer, required: false, description: "Filter by questionnaire type"
    argument :completed, Boolean, required: false, description: "Filter by completion status"
    argument :language, String, required: false, description: "Filter by language of completion"

    def resolve(subject_id: nil, respondent_id: nil, questionnaire_type: nil, completed: nil, language: nil)
      questionnaires = Questionnaire.all

      # Apply filters
      questionnaires = questionnaires.by_subject(subject_id) if subject_id.present?
      questionnaires = questionnaires.by_respondent(respondent_id) if respondent_id.present?
      questionnaires = questionnaires.by_type(questionnaire_type) if questionnaire_type.present?
      questionnaires = questionnaires.completed if completed == true
      questionnaires = questionnaires.in_progress if completed == false
      questionnaires = questionnaires.by_language(language) if language.present?

      questionnaires.order(created_at: :desc)
    end
  end

  class Questionnaire < BaseQuery
    type Types::QuestionnaireType, null: true
    description "Get a specific questionnaire by ID"

    argument :id, ID, required: true, description: "Questionnaire ID"

    def resolve(id:)
      Questionnaire.find_by(id: id)
    end
  end
end

