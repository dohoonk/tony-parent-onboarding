module Queries
  class Contract < BaseQuery
    description "Find a contract by ID"

    argument :id, ID, required: true, description: "Contract UUID"

    type Types::ContractType, null: true

    def resolve(id:)
      ::Contract.find_by(id: id)
    end
  end
end

