module Importers
  class QuestionnaireImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/questionnaires.csv')
      super(csv_path, Questionnaire)
    end

    protected

    def build_attributes(row)
      # Find subject (student) and respondent (parent)
      subject = find_record(Student, row['subject_id'], required: true)
      respondent = find_record(Parent, row['respondent_id'], required: true)
      
      # Parse question_answers JSONB
      question_answers = parse_json_field(row, 'question_answers', default: {})
      
      {
        id: row['id'],
        subject_id: subject.id,
        respondent_id: respondent.id,
        score: parse_integer(row, 'score', default: 0),
        started_at: parse_timestamp(row, 'started_at'),
        completed_at: parse_timestamp(row, 'completed_at'),
        question_answers: question_answers,
        questionnaire_type: parse_integer(row, 'type', default: 3),
        language_of_completion: row['language_of_completion'].presence || 'eng',
        census_person_id: row['census_person_id'].presence,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

