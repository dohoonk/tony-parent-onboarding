class OpenaiService
  MODEL = 'gpt-4o'
  VISION_MODEL = 'gpt-4o' # GPT-4o supports vision
  MAX_TOKENS = 1000
  TEMPERATURE = 0.7

  def initialize
    @client = OpenAI::Client.new(access_token: api_key)
  end

  # Generate a chat completion with streaming support
  # @param messages [Array<Hash>] Array of message hashes with role and content
  # @param stream [Boolean] Whether to stream the response
  # @param system_prompt [String] Optional system prompt
  # @return [Hash, Enumerator] Response hash or streaming enumerator
  def chat_completion(messages:, stream: false, system_prompt: nil)
    request_messages = messages.dup
    request_messages.unshift({ role: 'system', content: system_prompt }) if system_prompt

    params = {
      model: MODEL,
      messages: request_messages,
      max_tokens: MAX_TOKENS,
      temperature: TEMPERATURE,
      stream: stream
    }

    if stream
      @client.chat(
        parameters: params
      )
    else
      response = @client.chat(
        parameters: params
      )
      parse_response(response)
    end
  rescue OpenAI::Error => e
    Rails.logger.error("OpenAI API error: #{e.message}")
    raise ServiceError.new("AI service unavailable: #{e.message}")
  end

  # Stream chat completion chunks
  # @param messages [Array<Hash>] Array of message hashes
  # @param system_prompt [String] Optional system prompt
  # @yield [String] Yields content chunks as they arrive
  def stream_chat_completion(messages:, system_prompt: nil, &block)
    enum = chat_completion(messages: messages, stream: true, system_prompt: system_prompt)
    
    enum.each do |chunk|
      content = extract_content_from_chunk(chunk)
      block.call(content) if content.present?
    end
  rescue OpenAI::Error => e
    Rails.logger.error("OpenAI streaming error: #{e.message}")
    raise ServiceError.new("AI streaming unavailable: #{e.message}")
  end

  private

  def api_key
    Rails.application.credentials.openai_api_key || ENV['OPENAI_API_KEY']
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

