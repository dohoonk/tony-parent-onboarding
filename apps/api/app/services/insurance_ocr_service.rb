class InsuranceOcrService
  EXTRACTION_SCHEMA = {
    type: 'object',
    properties: {
      payer_name: {
        type: 'string',
        description: 'Insurance company name (e.g., Blue Cross Blue Shield, Aetna)'
      },
      insurance_company_name: {
        type: 'string',
        description: 'Full insurance company name (may be same as payer_name)'
      },
      member_id: {
        type: 'string',
        description: 'Member ID or policy number'
      },
      group_number: {
        type: 'string',
        description: 'Group number if present'
      },
      group_id: {
        type: 'string',
        description: 'Group ID (may be different from group_number)'
      },
      subscriber_name: {
        type: 'string',
        description: 'Name of the policyholder/subscriber'
      },
      plan_type: {
        type: 'string',
        description: 'Type of plan (e.g., PPO, HMO, EPO)'
      },
      effective_date: {
        type: 'string',
        description: 'Policy effective date if visible'
      },
      # Plan holder information
      plan_holder_first_name: {
        type: 'string',
        description: 'First name of the plan holder (may be different from subscriber)'
      },
      plan_holder_last_name: {
        type: 'string',
        description: 'Last name of the plan holder'
      },
      plan_holder_dob: {
        type: 'string',
        description: 'Date of birth of plan holder (format: YYYY-MM-DD)'
      },
      plan_holder_country: {
        type: 'string',
        description: 'Country of plan holder (default: US)'
      },
      plan_holder_state: {
        type: 'string',
        description: 'State of plan holder (2-letter code, e.g., CA, NY)'
      },
      plan_holder_city: {
        type: 'string',
        description: 'City of plan holder'
      },
      plan_holder_street_address: {
        type: 'string',
        description: 'Street address of plan holder'
      },
      plan_holder_zip_code: {
        type: 'string',
        description: 'ZIP code of plan holder'
      },
      plan_holder_legal_gender: {
        type: 'string',
        description: 'Legal gender of plan holder (M, F, or other)'
      },
      # Policy metadata
      kind: {
        type: 'integer',
        description: 'Policy kind: 0=unknown, 1=individual, 2=family'
      },
      level: {
        type: 'integer',
        description: 'Plan level: 0=unknown, 1=bronze, 2=silver, 3=gold'
      },
      eligibility: {
        type: 'integer',
        description: 'Eligibility status: 0=unknown, 1=active, 2=pending, 3=expired, 4=terminated'
      }
    },
    required: ['payer_name', 'member_id']
  }.freeze

  # Extract insurance information from card images using OpenAI Vision
  # @param front_image_url [String] S3 URL of front image
  # @param back_image_url [String] Optional S3 URL of back image
  # @return [Hash] Extracted data with confidence scores
  def self.extract(front_image_url:, back_image_url: nil)
    openai_service = OpenaiService.new
    
    # Build messages for vision API
    messages = [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: <<~PROMPT
              Extract insurance card information from these images. Return a JSON object with the following fields:
              
              **Required Fields:**
              - payer_name: Insurance company name (e.g., Blue Cross Blue Shield, Aetna)
              - member_id: Member ID or policy number
              
              **Optional Basic Fields:**
              - insurance_company_name: Full insurance company name (may be same as payer_name)
              - group_number: Group number if visible
              - group_id: Group ID (may be different from group_number)
              - subscriber_name: Name of the policyholder/subscriber
              - plan_type: Plan type (PPO, HMO, EPO, etc.)
              - effective_date: Policy effective date (format: YYYY-MM-DD)
              
              **Plan Holder Information (if visible on card):**
              - plan_holder_first_name: First name of plan holder
              - plan_holder_last_name: Last name of plan holder
              - plan_holder_dob: Date of birth (format: YYYY-MM-DD)
              - plan_holder_country: Country (default: US if not visible)
              - plan_holder_state: State (2-letter code: CA, NY, etc.)
              - plan_holder_city: City
              - plan_holder_street_address: Street address
              - plan_holder_zip_code: ZIP code
              - plan_holder_legal_gender: Legal gender (M, F, or other)
              
              **Policy Metadata (infer from card if possible):**
              - kind: Policy kind (0=unknown, 1=individual, 2=family) - infer from card if possible
              - level: Plan level (0=unknown, 1=bronze, 2=silver, 3=gold) - infer if visible
              - eligibility: Eligibility status (0=unknown, 1=active, 2=pending, 3=expired, 4=terminated) - default to 1 if card appears valid
              
              For each field, provide a confidence level: "high", "medium", or "low" based on how clearly the information is visible.
              
              Return JSON in this format:
              {
                "payer_name": {"value": "...", "confidence": "high|medium|low"},
                "member_id": {"value": "...", "confidence": "high|medium|low"},
                "insurance_company_name": {"value": "...", "confidence": "high|medium|low"},
                "group_id": {"value": "...", "confidence": "high|medium|low"},
                "plan_holder_first_name": {"value": "...", "confidence": "high|medium|low"},
                ...
              }
              
              Only include fields that are actually visible on the card. For fields not visible, omit them from the response.
            PROMPT
          },
          {
            type: 'image_url',
            image_url: { url: front_image_url }
          }
        ]
      }
    ]

    # Add back image if provided
    if back_image_url
      messages[0][:content] << {
        type: 'image_url',
        image_url: { url: back_image_url }
      }
    end

    # Call OpenAI Vision API
    response = openai_service.chat_completion(
      messages: messages,
      system_prompt: "You are an expert at reading insurance cards. Extract information accurately and provide confidence levels for each field."
    )

    # Parse and structure response
    parse_extraction_response(response[:content])
  rescue StandardError => e
    Rails.logger.error("OCR extraction failed: #{e.message}")
    raise ServiceError.new("Failed to extract insurance information: #{e.message}")
  end

  private

  def self.parse_extraction_response(content)
    # Try to extract JSON from response
    json_match = content.match(/```json\s*(\{.*?\})\s*```/m) || content.match(/(\{.*\})/m)
    
    if json_match
      data = JSON.parse(json_match[1], symbolize_names: true)
      structure_extracted_data(data)
    else
      raise JSON::ParserError, "No valid JSON found in OCR response"
    end
  end

  def self.structure_extracted_data(data)
    # Convert nested structure to flat structure with confidence
    result = {}
    confidence_scores = {}

    data.each do |key, value|
      if value.is_a?(Hash)
        raw_value = value[:value] || value['value']
        confidence = (value[:confidence] || value['confidence'] || 'low').to_s
        
        # Transform values based on field type
        transformed_value = transform_field_value(key, raw_value)
        
        result[key] = transformed_value
        confidence_scores[key] = confidence
      else
        transformed_value = transform_field_value(key, value)
        result[key] = transformed_value
        confidence_scores[key] = 'medium' # Default confidence
      end
    end

    {
      extracted_data: result,
      confidence_scores: confidence_scores
    }
  end

  def self.transform_field_value(field_name, value)
    return nil if value.blank?

    # Handle integer fields
    if %i[kind level eligibility].include?(field_name.to_sym)
      return value.to_i if value.is_a?(Numeric)
      return value.to_i if value.to_s.match?(/^\d+$/)
      return 0 # Default for unknown
    end

    # Handle date fields
    if field_name.to_s.include?('dob') || field_name.to_s.include?('date')
      return parse_date(value)
    end

    # Handle country/state - normalize to uppercase
    if field_name.to_s.include?('country') || field_name.to_s.include?('state')
      return value.to_s.strip.upcase
    end

    # Default: return as string, stripped
    value.to_s.strip
  end

  def self.parse_date(date_string)
    return nil if date_string.blank?
    
    # Try various date formats
    Date.parse(date_string)
  rescue ArgumentError
    # Try common formats
    formats = ['%Y-%m-%d', '%m/%d/%Y', '%m-%d-%Y', '%Y/%m/%d']
    formats.each do |format|
      begin
        return Date.strptime(date_string, format)
      rescue ArgumentError
        next
      end
    end
    nil
  end

  class ServiceError < StandardError; end
end

