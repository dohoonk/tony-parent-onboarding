module Types
  module Inputs
    class CreateAvailabilityWindowInput < Types::BaseInputObject
      description "Input for creating an availability window"

      argument :start_date, GraphQL::Types::ISO8601Date, required: false, description: "Start date for the availability window"
      argument :end_date, GraphQL::Types::ISO8601Date, required: false, description: "End date for the availability window"
      argument :timezone, String, required: false, description: "Timezone identifier (e.g., America/Los_Angeles)"
      argument :availability_json, GraphQL::Types::JSON, required: true, description: "Availability structure in JSON format"
    end
  end
end




