class CostEstimationService
  # Rule-based cost estimation based on insurance data
  # This is a simplified version - in production, this would query a config table or external API
  
  DEFAULT_COST_RANGES = {
    'blue_cross_blue_shield' => {
      'ppo' => { min: 20, max: 50 },
      'hmo' => { min: 15, max: 40 },
      'epo' => { min: 25, max: 55 }
    },
    'aetna' => {
      'ppo' => { min: 25, max: 60 },
      'hmo' => { min: 20, max: 45 },
      'epo' => { min: 30, max: 65 }
    },
    'unitedhealthcare' => {
      'ppo' => { min: 22, max: 55 },
      'hmo' => { min: 18, max: 42 },
      'epo' => { min: 28, max: 60 }
    },
    'cigna' => {
      'ppo' => { min: 20, max: 50 },
      'hmo' => { min: 15, max: 40 },
      'epo' => { min: 25, max: 55 }
    }
  }.freeze

  DEFAULT_RANGE = { min: 20, max: 50 }.freeze

  # Estimate cost based on insurance data
  # @param insurance_policy [InsurancePolicy] The confirmed insurance policy
  # @param session_type [String] Type of session (e.g., 'individual', 'family')
  # @param state [String] State code (e.g., 'CA', 'NY')
  # @return [Hash] Cost estimate with min, max, and currency
  def self.estimate(insurance_policy:, session_type: 'individual', state: nil)
    payer_name = normalize_payer_name(insurance_policy.payer_name)
    plan_type = normalize_plan_type(insurance_policy.plan_type)

    # Look up cost range
    cost_range = find_cost_range(payer_name, plan_type, state)

    # Adjust for session type if needed
    adjusted_range = adjust_for_session_type(cost_range, session_type)

    {
      min_cost: adjusted_range[:min],
      max_cost: adjusted_range[:max],
      currency: 'USD',
      payer_name: insurance_policy.payer_name,
      plan_type: insurance_policy.plan_type,
      session_type: session_type,
      state: state,
      estimated_at: Time.current
    }
  end

  private

  def self.normalize_payer_name(payer_name)
    return 'default' unless payer_name

    name = payer_name.downcase.strip
    
    # Map common variations to standard names
    case name
    when /blue.*cross/i, /bcbs/i, /bc.*bs/i
      'blue_cross_blue_shield'
    when /aetna/i
      'aetna'
    when /united.*health/i, /uhc/i
      'unitedhealthcare'
    when /cigna/i
      'cigna'
    else
      'default'
    end
  end

  def self.normalize_plan_type(plan_type)
    return 'ppo' unless plan_type

    type = plan_type.downcase.strip
    
    case type
    when /ppo/i
      'ppo'
    when /hmo/i
      'hmo'
    when /epo/i
      'epo'
    else
      'ppo' # Default to PPO
    end
  end

  def self.find_cost_range(payer_name, plan_type, state)
    # In production, this would query a database table or external service
    # For now, use the default ranges
    
    payer_ranges = DEFAULT_COST_RANGES[payer_name.to_sym]
    
    if payer_ranges && payer_ranges[plan_type.to_sym]
      payer_ranges[plan_type.to_sym]
    else
      DEFAULT_RANGE
    end
  end

  def self.adjust_for_session_type(cost_range, session_type)
    # Family sessions might have different pricing
    case session_type
    when 'family'
      {
        min: (cost_range[:min] * 1.2).round,
        max: (cost_range[:max] * 1.2).round
      }
    else
      cost_range
    end
  end
end

