module Types
  class TherapistMatchType < Types::BaseObject
    description "A matched therapist with score and rationale"

    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: true
    field :phone, String, null: true
    field :languages, [String], null: false
    field :specialties, [String], null: false
    field :modalities, [String], null: false
    field :bio, String, null: true
    field :capacity_available, Integer, null: false
    field :capacity_utilization, Float, null: false
    field :match_score, Integer, null: false
    field :match_rationale, String, null: false
    field :match_details, GraphQL::Types::JSON, null: true
  end
end

