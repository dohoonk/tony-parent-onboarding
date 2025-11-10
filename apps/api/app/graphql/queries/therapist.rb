module Queries
  class Therapist < BaseQuery
    description "Find a therapist by ID"

    argument :id, ID, required: true, description: "Therapist UUID"

    type Types::TherapistType, null: true

    def resolve(id:)
      ::Therapist.find_by(id: id)
    end
  end
end

