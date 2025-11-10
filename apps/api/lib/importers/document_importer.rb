module Importers
  class DocumentImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/documents.csv')
      super(csv_path, Document)
    end

    protected

    def build_attributes(row)
      # Parse JSONB fields
      urls = parse_json_field(row, 'urls', default: {})
      names = parse_json_field(row, 'names', default: {})
      
      # Parse version_date
      version_date = parse_date(row, 'version_date')
      
      {
        id: row['id'],
        version: parse_integer(row, 'version', default: 1),
        label: row['label'],
        checkboxes: row['checkboxes'].presence,
        version_date: version_date,
        urls: urls,
        names: names,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

