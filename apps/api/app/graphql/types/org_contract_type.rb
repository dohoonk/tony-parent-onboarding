module Types
  class OrgContractType < Types::BaseObject
    description "Join table linking organizations to contracts"

    field :id, ID, null: false
    field :organization_id, ID, null: false
    field :contract_id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :organization, Types::OrganizationType, null: false
    field :contract, Types::ContractType, null: false
  end
end

