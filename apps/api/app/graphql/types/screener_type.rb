module Types
  class ScreenerType < Types::BaseObject
    description "A clinical screener (PHQ-9, GAD-7, etc.)"

    field :id, ID, null: false
    field :key, String, null: false
    field :title, String, null: false
    field :version, String, null: false
    field :items, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end

