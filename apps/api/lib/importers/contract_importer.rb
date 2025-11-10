module Importers
  class ContractImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/contracts.csv')
      super(csv_path, Contract)
    end

    protected

    def build_attributes(row)
      # Parse arrays
      services = parse_array_field(row, 'services', default: [])
      
      # Parse JSONB fields
      terms = parse_json_field(row, 'terms', default: {})
      
      {
        id: row['id'],
        effective_date: parse_date(row, 'effective_date'),
        end_date: parse_date(row, 'end_date'),
        services: services,
        terms: terms,
        contract_url: row['contract_url'].presence,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

