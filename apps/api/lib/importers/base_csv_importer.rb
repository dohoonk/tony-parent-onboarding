require 'csv'

module Importers
  class BaseCsvImporter
    attr_reader :csv_path, :model_class, :stats

    def initialize(csv_path, model_class)
      @csv_path = csv_path
      @model_class = model_class
      @stats = {
        imported: 0,
        skipped: 0,
        errors: 0,
        error_details: []
      }
    end

    def import
      validate_csv_exists!
      
      puts "Importing #{model_class.name.pluralize} from #{csv_path}..."
      start_time = Time.current
      
      CSV.foreach(csv_path, headers: true).with_index do |row, index|
        process_row(row, index + 1)
      end
      
      duration = Time.current - start_time
      print_summary(duration)
      
      stats
    end

    protected

    # Override in subclasses to implement row processing
    def process_row(row, row_number)
      begin
        record_id = extract_id(row)
        return if record_id.blank?
        
        # Skip if already exists (idempotent)
        if record_exists?(record_id)
          stats[:skipped] += 1
          return
        end
        
        # Skip deleted records
        if deleted?(row)
          stats[:skipped] += 1
          return
        end
        
        # Build attributes
        attributes = build_attributes(row)
        
        # Create record
        record = model_class.new(attributes)
        
        if record.save
          stats[:imported] += 1
          print_progress if stats[:imported] % 10 == 0
        else
          handle_save_error(record, row_number)
        end
        
      rescue => e
        handle_processing_error(e, row, row_number)
      end
    end

    # Override in subclasses to extract the record ID
    def extract_id(row)
      row['id']
    end

    # Override in subclasses to check if record exists
    def record_exists?(id)
      model_class.exists?(id: id)
    end

    # Override in subclasses to check if record is deleted
    def deleted?(row)
      row['_fivetran_deleted'] == 'true'
    end

    # Override in subclasses to build attributes from CSV row
    def build_attributes(row)
      raise NotImplementedError, "Subclasses must implement build_attributes"
    end

    # Helper methods for common data transformations

    def parse_json_field(row, field_name, default: {})
      return default if row[field_name].blank? || row[field_name] == '{}'
      
      begin
        JSON.parse(row[field_name])
      rescue JSON::ParserError
        default
      end
    end

    def parse_array_field(row, field_name, default: [])
      return default if row[field_name].blank?
      
      begin
        parsed = JSON.parse(row[field_name])
        Array(parsed)
      rescue JSON::ParserError
        # Try splitting by comma if not JSON
        row[field_name].split(',').map(&:strip).reject(&:blank?)
      end
    end

    def parse_timestamp(row, field_name)
      return nil if row[field_name].blank?
      Time.parse(row[field_name]) rescue nil
    end

    def parse_date(row, field_name)
      return nil if row[field_name].blank?
      Date.parse(row[field_name]) rescue nil
    end

    def parse_integer(row, field_name, default: nil)
      return default if row[field_name].blank?
      row[field_name].to_i
    rescue ArgumentError
      default
    end

    def parse_boolean(row, field_name, default: false)
      return default if row[field_name].blank?
      value = row[field_name].to_s.downcase
      %w[true 1 yes t].include?(value)
    end

    def parse_uuid(row, field_name)
      return nil if row[field_name].blank?
      row[field_name]
    end

    def find_record(model_class, id, required: false)
      return nil if id.blank?
      
      record = model_class.find_by(id: id)
      
      if required && record.nil?
        raise "Required #{model_class.name} not found: #{id}"
      end
      
      record
    end

    private

    def validate_csv_exists!
      unless File.exist?(csv_path)
        raise "CSV file not found at #{csv_path}"
      end
    end

    def print_progress
      print '.'
      $stdout.flush
    end

    def handle_save_error(record, row_number)
      error_msg = "Row #{row_number} (#{record.id || 'new'}): #{record.errors.full_messages.join(', ')}"
      stats[:errors] += 1
      stats[:error_details] << error_msg
      puts "\n#{error_msg}"
    end

    def handle_processing_error(error, row, row_number)
      error_msg = "Row #{row_number} (#{row['id'] || 'unknown'}): #{error.message}"
      stats[:errors] += 1
      stats[:error_details] << error_msg
      puts "\n#{error_msg}"
      puts error.backtrace.first(3).join("\n") if Rails.env.development?
    end

    def print_summary(duration)
      puts "\n\nImport complete (#{duration.round(2)}s):"
      puts "  Imported: #{stats[:imported]}"
      puts "  Skipped: #{stats[:skipped]}"
      puts "  Errors: #{stats[:errors]}"
      
      if stats[:errors] > 0 && stats[:error_details].any?
        puts "\nFirst 10 errors:"
        stats[:error_details].first(10).each do |error|
          puts "  - #{error}"
        end
      end
    end
  end
end

