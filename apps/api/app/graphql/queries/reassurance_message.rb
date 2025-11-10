module Queries
  class ReassuranceMessage < BaseQuery
    description "Get AI-generated reassurance message"

    argument :trigger_point, String, required: true
    argument :context, GraphQL::Types::JSON, required: false

    type String, null: false

    def resolve(trigger_point:, context: {})
      FaqService.generate_reassurance(
        trigger_point: trigger_point,
        context: context || {}
      )
    rescue StandardError => e
      Rails.logger.error("Reassurance generation failed: #{e.message}")
      "You're doing great! We're here to support you every step of the way."
    end
  end
end

