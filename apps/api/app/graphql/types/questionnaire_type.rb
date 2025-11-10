module Types
  class QuestionnaireType < Types::BaseObject
    description "A questionnaire response with links to screeners"

    field :id, ID, null: false
    field :subject_id, ID, null: false
    field :respondent_id, ID, null: false
    field :score, Integer, null: true
    field :started_at, GraphQL::Types::ISO8601DateTime, null: true
    field :completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :question_answers, GraphQL::Types::JSON, null: false
    field :questionnaire_type, Integer, null: false
    field :language_of_completion, String, null: false
    field :census_person_id, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :subject, Types::StudentType, null: false
    field :respondent, Types::ParentType, null: false
    field :screener_response, Types::ScreenerResponseType, null: true

    # Computed fields
    field :screener_key, String, null: true
    field :completed, Boolean, null: false
    field :in_progress, Boolean, null: false
    field :duration_seconds, Integer, null: true

    def screener_key
      object.screener_key
    end

    def completed
      object.completed?
    end

    def in_progress
      object.in_progress?
    end

    def duration_seconds
      object.duration_seconds
    end
  end
end

