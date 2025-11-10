module Queries
  class AvailableScreeners < BaseQuery
    description "Get list of available clinical screeners"

    type [Types::ScreenerType], null: false

    def resolve
      Screener.all
    end
  end
end

