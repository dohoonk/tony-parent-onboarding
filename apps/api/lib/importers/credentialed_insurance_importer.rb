module Importers
  class CredentialedInsuranceImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/credentialed_insurances.csv')
      super(csv_path, CredentialedInsurance)
    end

    protected

    def build_attributes(row)
      # Parse parent insurance (self-referential)
      parent_credentialed_insurance_id = parse_uuid(row, 'parent_credentialed_insurance_id')
      
      # Parse arrays
      legacy_names = parse_array_field(row, 'legacy_names', default: [])
      
      {
        id: row['id'],
        parent_credentialed_insurance_id: parent_credentialed_insurance_id,
        name: row['name'],
        country: row['country'].presence || 'US',
        state: row['state'].presence,
        line_of_business: row['line_of_business'].presence,
        legacy_names: legacy_names,
        network_status: parse_integer(row, 'network_status', default: 0),
        associates_allowed: parse_boolean(row, 'associates_allowed', default: false),
        open_pm_name: row['open_pm_name'].presence,
        legacy_id: row['legacy_id'].presence,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

