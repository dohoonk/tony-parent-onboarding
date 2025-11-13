module Types
  class AvailabilityWindowType < Types::BaseObject
    description "An availability window representing when a parent, student, or therapist is available"

    field :id, ID, null: false
    field :owner_type, String, null: false
    field :owner_id, ID, null: false
    field :start_date, GraphQL::Types::ISO8601Date, null: false
    field :end_date, GraphQL::Types::ISO8601Date, null: true
    field :timezone, String, null: true
    field :availability_json, GraphQL::Types::JSON, null: true
    field :rrule, String, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end




