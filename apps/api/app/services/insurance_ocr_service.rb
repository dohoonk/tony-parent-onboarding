require 'base64'
require 'open-uri'

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
  # @param front_image_url [String] S3 URL or public URL of front image
  # @param back_image_url [String] Optional S3 URL or public URL of back image
  # @return [Hash] Extracted data with confidence scores
  def self.extract(front_image_url:, back_image_url: nil)
    openai_service = OpenaiService.new
    
    # Convert S3 URLs to base64-encoded images for OpenAI
    # OpenAI can't access private S3 URLs, so we need to download and encode
    front_image_data = prepare_image_for_openai(front_image_url)
    back_image_data = prepare_image_for_openai(back_image_url) if back_image_url
    
    # Build messages for vision API
    messages = [
      {
        role: 'user',
        content: [
          {
            type: 'text',
            text: <<~PROMPT
              You are extracting insurance card information from an image. This is a REAL insurance card with actual patient data.
              
              **STEP 1: First, carefully examine the entire image and describe what you see:**
              - What text labels are visible? (e.g., "Member Name:", "ID Number:", "Group Number:")
              - What actual values appear next to those labels?
              - Read the card from top to bottom, left to right
              - Note any text that might be partially obscured
              
              **STEP 2: Extract ONLY the actual values you can see:**
              - If you see "Member Name: JAMIE DOE", extract "JAMIE DOE" (not "Member Name")
              - If you see "ID Number: ABC123456789", extract "ABC123456789" (not "ID Number" or a placeholder)
              - If you see "Group Number: 123456", extract "123456" (not "Group Number" or a placeholder)
              
              **CRITICAL RULES:**
              1. NEVER use placeholder values like "Member Name", "ABC123", "123456", "XYZ123456789", "023457"
              2. NEVER extract the LABEL itself as the value (e.g., don't extract "Member Name" as the subscriber_name)
              3. If you cannot clearly see a value, set confidence to "low" or omit the field entirely
              4. Extract EXACTLY what is written on the card - do not modify, guess, or infer
              
              **IMPORTANT:** Look carefully at the card layout. Common insurance card formats:
              - Blue Cross Blue Shield: Look for "Member Name", "Identification Number" or "ID Number", "Group Number"
              - Cards may have information in different sections (top, middle, bottom)
              - Member ID may be labeled as "ID Number", "Member ID", "Policy Number", or "Subscriber ID"
              - Group number may be labeled as "Group Number", "Group #", "Group ID", or "Group"
              - Subscriber name may be labeled as "Member Name", "Subscriber Name", "Name", or "Policyholder Name"
              
              **Required Fields:**
              - payer_name: Insurance company name (e.g., "Blue Cross Blue Shield", "BlueCross BlueShield", "Aetna", "UnitedHealthcare")
                * For BCBS cards, look for "Blue Cross Blue Shield" or "BlueCross BlueShield" text
                * May include state/region (e.g., "Blue Cross Blue Shield of Montana")
              - member_id: Member ID or policy number (also called "Identification Number", "ID Number", "Subscriber ID")
                * Usually a combination of letters and numbers
                * May be labeled as "ID:", "ID Number:", "Member ID:", "Policy #:", etc.
              
              **Optional Basic Fields:**
              - insurance_company_name: Full insurance company name (may be same as payer_name or more specific)
              - group_number: Group number if visible (labeled as "Group Number", "Group #", "Group ID", etc.)
              - group_id: Group ID (may be different from group_number, or same if only one exists)
              - subscriber_name: Name of the policyholder/subscriber (labeled as "Member Name", "Subscriber Name", etc.)
                * Extract full name, we'll split into first/last later if needed
              - plan_type: Plan type (PPO, HMO, EPO, POS, etc.) - look for text like "PPO Plan", "HMO", etc.
              - effective_date: Policy effective date if visible (format: YYYY-MM-DD)
              
              **Plan Holder Information (if visible on card):**
              - plan_holder_first_name: First name of plan holder (extract from subscriber_name if full name is given)
              - plan_holder_last_name: Last name of plan holder (extract from subscriber_name if full name is given)
              - plan_holder_dob: Date of birth if visible (format: YYYY-MM-DD)
              - plan_holder_country: Country (default: "US" if not visible)
              - plan_holder_state: State (2-letter code: CA, NY, MT, etc.) - may be in company name or address
              - plan_holder_city: City if visible in address
              - plan_holder_street_address: Street address if visible
              - plan_holder_zip_code: ZIP code if visible
              - plan_holder_legal_gender: Legal gender if visible (M, F, or other)
              
              **Policy Metadata (infer from card if possible):**
              - kind: Policy kind (0=unknown, 1=individual, 2=family) - infer from card if it mentions "Individual" or "Family"
              - level: Plan level (0=unknown, 1=bronze, 2=silver, 3=gold) - infer if visible
              - eligibility: Eligibility status (0=unknown, 1=active, 2=pending, 3=expired, 4=terminated) - default to 1 if card appears valid
              
              **For Blue Cross Blue Shield cards specifically:**
              - Look for "BlueCross" and "BlueShield" text (may be written as one word or two)
              - Member ID is often labeled as "Identification Number" or "ID Number"
              - Group number is usually clearly labeled
              - Plan type (PPO, HMO) is often visible
              - May have state/region in the company name (e.g., "of Montana", "of California")
              
              **Extraction Guidelines:**
              - Read all text carefully, even if partially obscured by watermarks
              - Look in all sections of the card (top, middle, bottom, left, right)
              - Member ID and Group Number are critical - make sure to extract these accurately
              - **DO NOT use placeholder values like "Member Name", "ABC123", or "123456" - extract the ACTUAL values from the card**
              - If you see a name, extract it even if you can't determine first/last - we'll handle splitting
              - For dates, extract exactly as shown and we'll parse the format
              - If a field is not visible or unclear, set confidence to "low" or omit it - do NOT guess
              
              **VERIFICATION CHECKLIST (before returning JSON):**
              - subscriber_name: Is this an actual person's name? (NOT "Member Name", "Subscriber Name", or any label)
              - member_id: Is this the actual ID/policy number? (NOT "ABC123", "XYZ123456789", or any placeholder pattern)
              - group_number: Is this the actual group number? (NOT "123456", "023457", or any placeholder pattern)
              - payer_name: Is this the actual insurance company name? (NOT a generic placeholder)
              
              If any field contains placeholder-like values, set confidence to "low" and note in the response that the value may be unclear.
              
              For each field, provide a confidence level: "high", "medium", or "low" based on how clearly the information is visible.
              
              Return JSON in this format:
              {
                "payer_name": {"value": "Blue Cross Blue Shield", "confidence": "high"},
                "member_id": {"value": "ABC123456789", "confidence": "high"},
                "insurance_company_name": {"value": "Blue Cross Blue Shield of Montana", "confidence": "high"},
                "group_number": {"value": "123456", "confidence": "high"},
                "subscriber_name": {"value": "JAMIE DOE", "confidence": "high"},
                "plan_type": {"value": "PPO", "confidence": "high"},
                ...
              }
              
              Only include fields that are actually visible on the card. For fields not visible, omit them from the response.
              Always try to extract payer_name and member_id at minimum - these are critical fields.
            PROMPT
          },
          front_image_data
        ]
      }
    ]

    # Add back image if provided
    if back_image_data
      messages[0][:content] << back_image_data
    end

    # Call OpenAI Vision API
    Rails.logger.info("Calling OpenAI Vision API for OCR extraction")
    Rails.logger.debug("Front image URL: #{front_image_url}")
    Rails.logger.debug("Back image URL: #{back_image_url}") if back_image_url
    
    response = openai_service.chat_completion(
      messages: messages,
      system_prompt: "You are an expert at reading insurance cards. Extract information accurately and provide confidence levels for each field."
    )

    Rails.logger.debug("OpenAI Vision API response received")
    Rails.logger.debug("Response content length: #{response[:content]&.length || 0} characters")
    
    # Parse and structure response
    result = parse_extraction_response(response[:content])
    
    Rails.logger.info("OCR extraction completed successfully")
    Rails.logger.info("Extracted fields: #{result[:extracted_data].keys.join(', ')}")
    Rails.logger.debug("Full extraction result: #{result.inspect}")
    
    result
  rescue JSON::ParserError => e
    Rails.logger.error("OCR JSON parsing failed: #{e.message}")
    Rails.logger.error("Raw response content: #{response[:content]&.first(500)}") if defined?(response)
    raise ServiceError.new("Failed to parse OCR response: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("OCR extraction failed: #{e.class.name} - #{e.message}")
    Rails.logger.error(e.backtrace.join("\n"))
    raise ServiceError.new("Failed to extract insurance information: #{e.message}")
  end

  private

  def self.parse_extraction_response(content)
    Rails.logger.debug("Parsing OCR response...")
    
    # Try to extract JSON from response (may have markdown code blocks)
    json_match = content.match(/```json\s*(\{.*?\})\s*```/m) || content.match(/(\{.*\})/m)
    
    if json_match
      Rails.logger.debug("Found JSON in response, parsing...")
      data = JSON.parse(json_match[1], symbolize_names: true)
      Rails.logger.debug("Parsed JSON keys: #{data.keys.join(', ')}")
      structure_extracted_data(data)
    else
      Rails.logger.error("No valid JSON found in OCR response")
      Rails.logger.error("Response content preview: #{content.first(500)}")
      raise JSON::ParserError, "No valid JSON found in OCR response. Response preview: #{content.first(200)}"
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
        
        # Validate that we didn't extract placeholder values
        if is_placeholder_value?(key, transformed_value)
          Rails.logger.warn("Detected placeholder value for #{key}: #{transformed_value.inspect}")
          # Set confidence to low and keep the value (user can manually correct)
          confidence = 'low'
        end
        
        result[key] = transformed_value
        confidence_scores[key] = confidence
      else
        transformed_value = transform_field_value(key, value)
        
        # Validate placeholder values
        if is_placeholder_value?(key, transformed_value)
          Rails.logger.warn("Detected placeholder value for #{key}: #{transformed_value.inspect}")
        end
        
        result[key] = transformed_value
        confidence_scores[key] = 'medium' # Default confidence
      end
    end

    {
      extracted_data: result,
      confidence_scores: confidence_scores
    }
  end

  # Check if a value looks like a placeholder (template card)
  # @param field_name [Symbol, String] Field name
  # @param value [String] Extracted value
  # @return [Boolean] True if value appears to be a placeholder
  def self.is_placeholder_value?(field_name, value)
    return false if value.blank?
    
    value_str = value.to_s.strip
    
    # Common placeholder patterns
    placeholder_patterns = {
      subscriber_name: [
        /^member\s+name$/i,
        /^subscriber\s+name$/i,
        /^name$/i,
        /^policyholder\s+name$/i,
        /^insured\s+name$/i,
        /^patient\s+name$/i
      ],
      member_id: [
        /^xyz\d+$/i,
        /^abc\d+$/i,
        /^123456789$/,
        /^sample\d*$/i,
        /^test\d*$/i,
        /^placeholder/i
      ],
      group_number: [
        /^023457$/,
        /^123456$/,
        /^000000$/,
        /^sample$/i,
        /^test$/i
      ],
      payer_name: [
        /^sample\s+insurance/i,
        /^test\s+insurance/i
      ]
    }
    
    patterns = placeholder_patterns[field_name.to_sym] || []
    patterns.any? { |pattern| value_str.match?(pattern) }
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

  # Prepare image for OpenAI Vision API
  # Downloads image if it's an S3 URL and converts to base64, or uses URL directly if public
  # @param image_url [String] S3 URL or public URL
  # @return [Hash] Image content hash for OpenAI API
  def self.prepare_image_for_openai(image_url)
    return nil if image_url.blank?
    
    # Skip fake/example URLs (for testing/development)
    if image_url.include?('example.com') || image_url.include?('localhost') || image_url.include?('127.0.0.1')
      Rails.logger.warn("Skipping OCR for fake/example URL: #{image_url}")
      raise ServiceError.new("Invalid image URL: Please upload a real image first")
    end
    
    # Check if it's an S3 URL (private bucket)
    if image_url.include?('amazonaws.com') || image_url.include?('s3.')
      Rails.logger.info("Detected S3 URL, downloading and encoding as base64: #{image_url}")
      
      begin
        # Download image from S3
        image_data = download_image_from_s3(image_url)
        
        # Convert to base64
        base64_data = Base64.strict_encode64(image_data)
        
        # Determine content type from URL or default to jpeg
        content_type = determine_content_type(image_url)
        
        {
          type: 'image_url',
          image_url: {
            url: "data:#{content_type};base64,#{base64_data}"
          }
        }
      rescue StandardError => e
        Rails.logger.error("Failed to download/encode S3 image: #{e.message}")
        # Fallback: try using URL directly (might work if bucket is public)
        {
          type: 'image_url',
          image_url: { url: image_url }
        }
      end
    else
      # Public URL - use directly
      Rails.logger.debug("Using public URL directly: #{image_url}")
      {
        type: 'image_url',
        image_url: { url: image_url }
      }
    end
  end

  # Download image from S3 URL
  # @param s3_url [String] S3 URL (can be presigned or regular S3 URL)
  # @return [String] Image binary data
  def self.download_image_from_s3(s3_url)
    require 'open-uri'
    require 'net/http'
    
    # Parse S3 URL to extract bucket and key, or use presigned URL
    if s3_url.include?('?') && (s3_url.include?('X-Amz') || s3_url.include?('Signature'))
      # Presigned URL - download directly via HTTP
      Rails.logger.debug("Downloading from presigned URL")
      URI.open(s3_url, 'rb', read_timeout: 30).read
    else
      # Regular S3 URL - generate presigned read URL or use AWS SDK
      # Extract bucket and key from URL
      uri = URI.parse(s3_url)
      
      # Handle different S3 URL formats:
      # https://bucket.s3.region.amazonaws.com/key
      # https://s3.region.amazonaws.com/bucket/key
      # https://bucket.s3.amazonaws.com/key
      if uri.host.include?('.s3.')
        # Format: bucket.s3.region.amazonaws.com or bucket.s3.amazonaws.com
        parts = uri.host.split('.')
        bucket_name = parts[0]
        key = uri.path[1..-1] # Remove leading slash
      elsif uri.host.start_with?('s3.')
        # Format: s3.region.amazonaws.com/bucket/key
        path_parts = uri.path.split('/')
        bucket_name = path_parts[1]
        key = path_parts[2..-1].join('/')
      else
        raise ServiceError.new("Unable to parse S3 URL: #{s3_url}")
      end
      
      Rails.logger.debug("Downloading from S3: bucket=#{bucket_name}, key=#{key}")
      
      # Try to generate presigned URL first (more efficient)
      begin
        s3_service = S3Service.new
        presigned_url = s3_service.presigned_read_url(key: key, expiration: 300) # 5 minutes
        Rails.logger.debug("Generated presigned URL, downloading...")
        URI.open(presigned_url, 'rb', read_timeout: 30).read
      rescue StandardError => presign_error
        Rails.logger.warn("Presigned URL generation failed, using AWS SDK: #{presign_error.message}")
        
        # Fallback: use AWS SDK directly
        s3_client = Aws::S3::Client.new(
          region: ENV.fetch('AWS_REGION', 'us-east-1'),
          access_key_id: ENV['AWS_ACCESS_KEY_ID'] || Rails.application.credentials.aws_access_key_id,
          secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'] || Rails.application.credentials.aws_secret_access_key
        )
        
        response = s3_client.get_object(bucket: bucket_name, key: key)
        response.body.read
      end
    end
  rescue StandardError => e
    Rails.logger.error("S3 download failed: #{e.message}")
    Rails.logger.error("S3 URL was: #{s3_url}")
    raise ServiceError.new("Failed to download image from S3: #{e.message}")
  end

  # Determine content type from URL or file extension
  # @param url [String] Image URL
  # @return [String] MIME type
  def self.determine_content_type(url)
    case url.downcase
    when /\.png/
      'image/png'
    when /\.jpg|\.jpeg/
      'image/jpeg'
    when /\.gif/
      'image/gif'
    when /\.webp/
      'image/webp'
    else
      'image/jpeg' # Default
    end
  end

  class ServiceError < StandardError; end
end

