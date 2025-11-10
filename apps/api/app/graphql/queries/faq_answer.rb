module Queries
  class FaqAnswer < BaseQuery
    description "Get AI-powered FAQ answer"

    argument :question, String, required: true
    argument :context, GraphQL::Types::JSON, required: false

    type String, null: false

    def resolve(question:, context: {})
      FaqService.answer_question(
        question: question,
        context: context || {}
      )
    rescue StandardError => e
      Rails.logger.error("FAQ query failed: #{e.message}")
      "I'm here to help! Please feel free to reach out to our support team if you have any questions."
    end
  end
end

