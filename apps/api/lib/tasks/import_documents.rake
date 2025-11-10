namespace :import do
  desc "Import documents from CSV"
  task documents: :environment do
    importer = Importers::DocumentImporter.new
    importer.import
  end

  # Legacy implementation (kept for reference)
  task documents_legacy: :environment do
    require 'csv'
    require 'json'
    
    csv_path = Rails.root.join('../../devdocs/documents.csv')
    
    unless File.exist?(csv_path)
      puts "Error: CSV file not found at #{csv_path}"
      exit 1
    end

    puts "Importing documents from #{csv_path}..."
    
    imported = 0
    skipped = 0
    errors = 0
    
    CSV.foreach(csv_path, headers: true) do |row|
      begin
        document_id = row['id']
        next if document_id.blank?
        
        # Skip if already exists (idempotent)
        if Document.exists?(id: document_id)
          skipped += 1
          next
        end
        
        # Skip deleted records
        if row['_fivetran_deleted'] == 'true'
          skipped += 1
          next
        end
        
        # Parse JSONB fields
        urls = {}
        if row['urls'].present? && row['urls'] != '{}'
          begin
            urls = JSON.parse(row['urls'])
          rescue JSON::ParserError
            urls = {}
          end
        end
        
        names = {}
        if row['names'].present? && row['names'] != '{}'
          begin
            names = JSON.parse(row['names'])
          rescue JSON::ParserError
            names = {}
          end
        end
        
        # Parse version_date
        version_date = nil
        if row['version_date'].present?
          begin
            version_date = Date.parse(row['version_date'])
          rescue ArgumentError
            version_date = nil
          end
        end
        
        # Parse timestamps
        parse_timestamp = ->(str) {
          return nil if str.blank?
          Time.parse(str) rescue nil
        }
        
        # Build document attributes
        document_attrs = {
          id: document_id,
          version: row['version']&.to_i || 1,
          label: row['label'],
          checkboxes: row['checkboxes'].presence,
          version_date: version_date,
          urls: urls,
          names: names,
          created_at: parse_timestamp.call(row['created_at']) || Time.current,
          updated_at: parse_timestamp.call(row['updated_at']) || Time.current
        }
        
        document = Document.new(document_attrs)
        
        if document.save
          imported += 1
          print '.' if imported % 10 == 0
        else
          puts "\nError saving document #{document_id}: #{document.errors.full_messages.join(', ')}"
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

