module Types
  class TherapistMatchType < Types::BaseObject
    description "A matched therapist with score and rationale"

    field :id, ID, null: false
    field :name, String, null: false
    field :languages, [String], null: false
    field :specialties, [String], null: false
    field :bio, String, null: false
    field :match_score, Integer, null: false
    field :match_rationale, String, null: false
  end
end

