module Mutations
  class SubmitScreener < BaseMutation
    description "Submit a clinical screener response"

    argument :input, Types::Inputs::SubmitScreenerInput, required: true

    field :response, Types::ScreenerResponseType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { response: nil, errors: ["Authentication required"] }
      end

      session = parent.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { response: nil, errors: ["Session not found"] }
      end

      screener = Screener.find_by(key: input.screener_key)
      
      unless screener
        return { response: nil, errors: ["Screener not found"] }
      end

      # Create screener response
      response = ScreenerResponse.new(
        onboarding_session: session,
        screener: screener,
        answers_json: input.answers
      )

      # Calculate score
      response.score = calculate_screener_score(input.answers, screener)

      if response.save
        # Generate AI interpretation
        begin
          interpretation_data = ScreenerInterpretationService.interpret(response)
          response.update!(
            interpretation_text: interpretation_data[:interpretation_text]
          )
        rescue StandardError => e
          Rails.logger.error("Failed to generate interpretation: #{e.message}")
          # Continue without interpretation - response is still saved
        end

        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: response,
          after: response.attributes
        )

        { response: response, errors: [] }
      else
        { response: nil, errors: response.errors.full_messages }
      end
    end

    private

    def calculate_screener_score(answers, screener)
      # Sum all answer values
      answers.values.sum
    rescue StandardError
      0
    end
  end
end

