module Importers
  class OrganizationImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/orgs.csv')
      super(csv_path, Organization)
      @parent_links = {}
    end

    def import
      result = super
      apply_deferred_parent_links
      result
    end

    protected

    def process_row(row, row_number)
      child_id = row['id']
      parent_id = parse_uuid(row, 'parent_organization_id')
      @parent_links[child_id] = parent_id if parent_id.present?

      super
    end

    def build_attributes(row)
      # Parse parent organization (self-referential)
      parent_organization_id = parse_uuid(row, 'parent_organization_id')
      child_id = row['id']
      resolved_parent_id = if parent_organization_id.present? && Organization.exists?(id: parent_organization_id)
                             parent_organization_id
                           else
                             nil
                           end
      
      # Parse JSONB fields
      config = parse_json_field(row, 'config', default: {})
      migration_details = parse_json_field(row, 'migration_details', default: {})
      
      {
        id: child_id,
        parent_organization_id: resolved_parent_id,
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

    private

    def apply_deferred_parent_links
      return if @parent_links.blank?

      @parent_links.each do |child_id, parent_id|
        next if parent_id.blank?
        next unless Organization.exists?(id: child_id)

        if Organization.exists?(id: parent_id)
          Organization.where(id: child_id).update_all(parent_organization_id: parent_id)
        else
          Rails.logger.warn("Organization import: parent #{parent_id} not found for child #{child_id}, leaving parent_organization_id nil")
        end
      end
    end
  end
end

