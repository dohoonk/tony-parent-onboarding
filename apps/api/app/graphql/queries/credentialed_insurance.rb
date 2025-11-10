module Queries
  class CredentialedInsurance < BaseQuery
    description "Find a credentialed insurance by ID"

    argument :id, ID, required: true, description: "Credentialed Insurance UUID"

    type Types::CredentialedInsuranceType, null: true

    def resolve(id:)
      ::CredentialedInsurance.find_by(id: id)
    end
  end
end

