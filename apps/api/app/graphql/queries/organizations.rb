module Queries
  class Organizations < BaseQuery
    description "List all organizations with optional filtering"

    argument :kind, Types::OrganizationKindEnum, required: false, description: "Filter by organization kind (district or school)"
    argument :parent_id, ID, required: false, description: "Filter by parent organization ID"
    argument :market_id, ID, required: false, description: "Filter by market ID"
    argument :enabled_only, Boolean, required: false, default_value: false, description: "Only return enabled organizations"
    argument :limit, Integer, required: false, default_value: 50, description: "Maximum number of results"
    argument :offset, Integer, required: false, default_value: 0, description: "Offset for pagination"

    type [Types::OrganizationType], null: false

    def resolve(
      kind: nil,
      parent_id: nil,
      market_id: nil,
      enabled_only: false,
      limit: 50,
      offset: 0
    )
      scope = ::Organization.all

      scope = scope.where(kind: kind) if kind.present?
      scope = scope.by_parent(parent_id) if parent_id.present?
      scope = scope.by_market(market_id) if market_id.present?
      scope = scope.enabled if enabled_only

      scope.limit(limit).offset(offset)
    end
  end
end

