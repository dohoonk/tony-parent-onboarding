module Mutations
  class EstimateCost < BaseMutation
    description "Estimate out-of-pocket cost based on insurance data"

    argument :session_id, ID, required: true
    argument :session_type, String, required: false, default_value: "individual"
    argument :state, String, required: false

    field :cost_estimate, Types::CostEstimateType, null: false
    field :errors, [String], null: false

    def resolve(session_id:, session_type:, state:)
      require_authentication!
      
      session = current_user.onboarding_sessions.find_by(id: session_id)
      
      unless session
        return { cost_estimate: nil, errors: ["Session not found"] }
      end

      # Get confirmed insurance policy
      insurance_policy = session.insurance_policy
      
      unless insurance_policy
        return { cost_estimate: nil, errors: ["Insurance policy not found. Please complete insurance verification first."] }
      end

      # Generate cost estimate
      estimate_data = CostEstimationService.estimate(
        insurance_policy: insurance_policy,
        session_type: session_type,
        state: state
      )

      # Create or update cost estimate
      cost_estimate = session.cost_estimate || CostEstimate.new(onboarding_session: session)
      cost_estimate.assign_attributes(estimate_data)
      
      if cost_estimate.save
        # Log audit trail
        AuditLog.log_access(
          actor: current_user,
          action: 'read',
          entity: cost_estimate
        )

        { cost_estimate: cost_estimate, errors: [] }
      else
        { cost_estimate: nil, errors: cost_estimate.errors.full_messages }
      end
    rescue StandardError => e
      Rails.logger.error("Cost estimation failed: #{e.message}")
      { cost_estimate: nil, errors: ["Failed to generate cost estimate: #{e.message}"] }
    end
  end
end

