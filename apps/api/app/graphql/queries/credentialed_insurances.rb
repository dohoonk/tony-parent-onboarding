module Queries
  class CredentialedInsurances < BaseQuery
    description "List all credentialed insurances with optional filtering"

    argument :name, String, required: false, description: "Filter by insurance name (partial match)"
    argument :country, String, required: false, description: "Filter by country"
    argument :state, String, required: false, description: "Filter by state"
    argument :in_network_only, Boolean, required: false, default_value: false, description: "Only return in-network insurances"
    argument :out_of_network_only, Boolean, required: false, default_value: false, description: "Only return out-of-network insurances"
    argument :limit, Integer, required: false, default_value: 50, description: "Maximum number of results"
    argument :offset, Integer, required: false, default_value: 0, description: "Offset for pagination"

    type [Types::CredentialedInsuranceType], null: false

    def resolve(
      name: nil,
      country: nil,
      state: nil,
      in_network_only: false,
      out_of_network_only: false,
      limit: 50,
      offset: 0
    )
      scope = ::CredentialedInsurance.all

      scope = scope.by_name(name) if name.present?
      scope = scope.by_country(country) if country.present?
      scope = scope.by_state(state) if state.present?
      scope = scope.in_network if in_network_only
      scope = scope.out_of_network if out_of_network_only

      scope.limit(limit).offset(offset)
    end
  end
end

