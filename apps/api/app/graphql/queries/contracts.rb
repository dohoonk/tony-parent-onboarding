module Queries
  class Contracts < BaseQuery
    description "List all contracts with optional filtering"

    argument :active_only, Boolean, required: false, default_value: false, description: "Only return active contracts"
    argument :expired_only, Boolean, required: false, default_value: false, description: "Only return expired contracts"
    argument :upcoming_only, Boolean, required: false, default_value: false, description: "Only return upcoming contracts"
    argument :with_service, String, required: false, description: "Filter by service name"
    argument :limit, Integer, required: false, default_value: 50, description: "Maximum number of results"
    argument :offset, Integer, required: false, default_value: 0, description: "Offset for pagination"

    type [Types::ContractType], null: false

    def resolve(
      active_only: false,
      expired_only: false,
      upcoming_only: false,
      with_service: nil,
      limit: 50,
      offset: 0
    )
      scope = ::Contract.all

      scope = scope.active if active_only
      scope = scope.expired if expired_only
      scope = scope.upcoming if upcoming_only
      scope = scope.with_service(with_service) if with_service.present?

      scope.limit(limit).offset(offset)
    end
  end
end

