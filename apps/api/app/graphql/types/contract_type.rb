module Types
  class ContractType < Types::BaseObject
    description "A contract defining services and terms"

    field :id, ID, null: false
    field :effective_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :services, [String], null: false
    field :terms, GraphQL::Types::JSON, null: true
    field :contract_url, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :organizations, [Types::OrganizationType], null: false
    field :org_contracts, [Types::OrgContractType], null: false

    # Computed fields
    field :active, Boolean, null: false
    field :expired, Boolean, null: false
    field :upcoming, Boolean, null: false

    # Computed field resolvers
    def active
      object.active?
    end

    def expired
      object.expired?
    end

    def upcoming
      object.upcoming?
    end
  end
end

