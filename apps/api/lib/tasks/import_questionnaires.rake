namespace :import do
  desc "Import questionnaires from CSV"
  task questionnaires: :environment do
    importer = Importers::QuestionnaireImporter.new
    importer.import
  end

  # Legacy implementation (kept for reference)
  task questionnaires_legacy: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/questionnaires.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing questionnaires from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        questionnaire_id = row['id']
        next if questionnaire_id.blank?
        
        # Skip if already exists (idempotent)
        if Questionnaire.exists?(id: questionnaire_id)
          skipped += 1
          next
        end
        
        # Skip deleted records
        if row['_fivetran_deleted'] == 'true'
          skipped += 1
          next
        end
        
        # Find subject (student) and respondent (parent)
        subject = Student.find_by(id: row['subject_id'])
        respondent = Parent.find_by(id: row['respondent_id'])
        
        unless subject && respondent
          puts "Warning: Skipping questionnaire #{questionnaire_id} - subject or respondent not found"
          skipped += 1
          next
        end
        
        # Parse question_answers JSONB
        question_answers = {}
        if row['question_answers'].present? && row['question_answers'] != '{}'
          begin
            question_answers = JSON.parse(row['question_answers'])
          rescue JSON::ParserError
            question_answers = {}
          end
        end
        
        # Parse timestamps
        parse_timestamp = ->(str) {
          return nil if str.blank?
          Time.parse(str) rescue nil
        }
        
        # Build questionnaire attributes
        questionnaire_attrs = {
          id: questionnaire_id,
          subject_id: subject.id,
          respondent_id: respondent.id,
          score: row['score']&.to_i || 0,
          started_at: parse_timestamp.call(row['started_at']),
          completed_at: parse_timestamp.call(row['completed_at']),
          question_answers: question_answers,
          questionnaire_type: row['type']&.to_i || 3, # Default to custom_intake
          language_of_completion: row['language_of_completion'].presence || 'eng',
          census_person_id: row['census_person_id'].presence,
          created_at: parse_timestamp.call(row['created_at']) || Time.current,
          updated_at: parse_timestamp.call(row['updated_at']) || Time.current
        }
        
        questionnaire = Questionnaire.new(questionnaire_attrs)
        
        if questionnaire.save
          imported += 1
          print '.' if imported % 10 == 0
        else
          puts "\nError saving questionnaire #{questionnaire_id}: #{questionnaire.errors.full_messages.join(', ')}"
          errors += 1
        end
        
      rescue => e
        puts "\nError processing row #{row['id']}: #{e.message}"
        puts e.backtrace.first(3).join("\n")
        errors += 1
      end
    end
    
    puts "\n\nImport complete:"
    puts "  Imported: #{imported}"
    puts "  Skipped: #{skipped}"
    puts "  Errors: #{errors}"
  end
end

