module Importers
  class OrganizationImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/orgs.csv')
      super(csv_path, Organization)
    end

    protected

    def build_attributes(row)
      # Parse parent organization (self-referential)
      parent_organization_id = parse_uuid(row, 'parent_organization_id')
      
      # Parse JSONB fields
      config = parse_json_field(row, 'config', default: {})
      migration_details = parse_json_field(row, 'migration_details', default: {})
      
      {
        id: row['id'],
        parent_organization_id: parent_organization_id,
        kind: row['kind'] == '1' ? 'district' : 'school', # CSV uses 1=district, 2=school
        slug: row['slug'],
        name: row['name'],
        tzdb: row['tzdb'].presence,
        market_id: parse_uuid(row, 'market_id'),
        internal_name: row['internal_name'].presence,
        config: config,
        enabled_at: parse_timestamp(row, 'enabled_at'),
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

