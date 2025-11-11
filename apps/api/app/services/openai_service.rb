class OpenaiService
  MODEL = 'gpt-4o'
  VISION_MODEL = 'gpt-4o' # GPT-4o supports vision
  MAX_TOKENS = 1000
  TEMPERATURE = 0.7

  def initialize
    @client = OpenAI::Client.new(access_token: api_key)
  end

  # Generate a chat completion
  # @param messages [Array<Hash>] Array of message hashes with role and content
  # @param system_prompt [String] Optional system prompt
  # @return [Hash] Response hash
  def chat_completion(messages:, system_prompt: nil)
    request_messages = messages.dup
    request_messages.unshift({ role: 'system', content: system_prompt }) if system_prompt

    # Detect if this is a vision request (has image_url in content)
    has_images = request_messages.any? do |msg|
      msg[:content].is_a?(Array) && msg[:content].any? { |item| item.is_a?(Hash) && item[:type] == 'image_url' }
    end
    
    model = has_images ? VISION_MODEL : MODEL
    max_tokens = has_images ? 2000 : MAX_TOKENS # Vision responses need more tokens

    params = {
      model: model,
      messages: request_messages,
      max_tokens: max_tokens,
      temperature: TEMPERATURE
    }

    response = @client.chat(parameters: params)
    parse_response(response)
  rescue OpenAI::Error => e
    Rails.logger.error("=" * 80)
    Rails.logger.error("OpenAI API Error")
    Rails.logger.error("Error Type: #{e.class.name}")
    Rails.logger.error("Message: #{e.message}")
    Rails.logger.error("Status: #{e.response&.dig('status') || 'unknown'}")
    Rails.logger.error("=" * 80)
    raise ServiceError.new("AI service unavailable: #{e.message}")
  end

  # Stream chat completion chunks
  # @param messages [Array<Hash>] Array of message hashes
  # @param system_prompt [String] Optional system prompt
  # @yield [String] Yields content chunks as they arrive
  def stream_chat_completion(messages:, system_prompt: nil, &block)
    raise ArgumentError, "Block is required for streaming" unless block_given?

    request_messages = messages.dup
    request_messages.unshift({ role: 'system', content: system_prompt }) if system_prompt

    has_images = request_messages.any? do |msg|
      msg[:content].is_a?(Array) && msg[:content].any? { |item| item.is_a?(Hash) && item[:type] == 'image_url' }
    end

    model = has_images ? VISION_MODEL : MODEL
    max_tokens = has_images ? 2000 : MAX_TOKENS

    params = {
      model: model,
      messages: request_messages,
      max_tokens: max_tokens,
      temperature: TEMPERATURE,
      stream: proc do |chunk, _bytesize|
        content = extract_content_from_chunk(chunk)
        block.call(content) if content.present?
      end
    }

    @client.chat(parameters: params)
  rescue OpenAI::Error => e
    Rails.logger.error("OpenAI streaming error: #{e.message}")
    raise ServiceError.new("AI streaming unavailable: #{e.message}")
  end

  private

  def api_key
    key = Rails.application.credentials.openai_api_key || ENV['OPENAI_API_KEY']
    
    if key.blank?
      Rails.logger.error("=" * 80)
      Rails.logger.error("OPENAI API KEY MISSING!")
      Rails.logger.error("Set OPENAI_API_KEY environment variable or add to Rails credentials")
      Rails.logger.error("=" * 80)
      raise ServiceError.new("OpenAI API key is not configured. Set OPENAI_API_KEY environment variable.")
    end
    
    # Log first few characters for debugging (but not the full key)
    if Rails.env.development?
      Rails.logger.debug("OpenAI API key found: #{key[0..10]}... (length: #{key.length})")
    end
    
    key
  end

  def parse_response(response)
    {
      content: response.dig('choices', 0, 'message', 'content'),
      finish_reason: response.dig('choices', 0, 'finish_reason'),
      usage: response['usage']
    }
  end

  def extract_content_from_chunk(chunk)
    chunk.dig('choices', 0, 'delta', 'content')
  end

  class ServiceError < StandardError; end
end

