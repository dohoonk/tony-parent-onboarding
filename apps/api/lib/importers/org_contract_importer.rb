module Importers
  class OrgContractImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/org_contracts.csv')
      super(csv_path, OrgContract)
    end

    protected

    def extract_id(row)
      # Use composite key for idempotency check
      "#{row['organization_id']}-#{row['contract_id']}"
    end

    def record_exists?(composite_id)
      org_id, contract_id = composite_id.split('-')
      OrgContract.exists?(organization_id: org_id, contract_id: contract_id)
    end

    def build_attributes(row)
      organization = find_record(Organization, row['organization_id'], required: true)
      contract = find_record(Contract, row['contract_id'], required: true)
      
      {
        organization_id: organization.id,
        contract_id: contract.id,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

