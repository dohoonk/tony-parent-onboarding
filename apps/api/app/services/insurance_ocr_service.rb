class InsuranceOcrService
  EXTRACTION_SCHEMA = {
    type: 'object',
    properties: {
      payer_name: {
        type: 'string',
        description: 'Insurance company name (e.g., Blue Cross Blue Shield, Aetna)'
      },
      member_id: {
        type: 'string',
        description: 'Member ID or policy number'
      },
      group_number: {
        type: 'string',
        description: 'Group number if present'
      },
      subscriber_name: {
        type: 'string',
        description: 'Name of the policyholder'
      },
      plan_type: {
        type: 'string',
        description: 'Type of plan (e.g., PPO, HMO, EPO)'
      },
      effective_date: {
        type: 'string',
        description: 'Policy effective date if visible'
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
              - payer_name: Insurance company name
              - member_id: Member ID or policy number
              - group_number: Group number (if visible)
              - subscriber_name: Policyholder name (if visible)
              - plan_type: Plan type like PPO, HMO (if visible)
              - effective_date: Effective date (if visible)
              
              For each field, also provide a confidence level: "high", "medium", or "low" based on how clearly the information is visible.
              
              Return JSON in this format:
              {
                "payer_name": {"value": "...", "confidence": "high|medium|low"},
                "member_id": {"value": "...", "confidence": "high|medium|low"},
                ...
              }
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
        result[key] = value[:value] || value['value']
        confidence_scores[key] = (value[:confidence] || value['confidence'] || 'low').to_s
      else
        result[key] = value
        confidence_scores[key] = 'medium' # Default confidence
      end
    end

    {
      extracted_data: result,
      confidence_scores: confidence_scores
    }
  end

  class ServiceError < StandardError; end
end

