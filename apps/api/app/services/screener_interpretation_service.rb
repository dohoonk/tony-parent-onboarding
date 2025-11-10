class ScreenerInterpretationService
  INTERPRETATION_PROMPT = <<~PROMPT
    You are a compassionate mental health professional helping a parent understand their child's assessment results.
    
    Given the following screener responses and score, provide:
    1. A warm, supportive interpretation in plain language (avoid clinical jargon)
    2. A risk level: "low", "moderate", or "high"
    3. Reassuring context about what the results mean
    
    Guidelines:
    - Use supportive, non-alarming language
    - Normalize the experience
    - Emphasize that this is just one piece of information
    - Avoid diagnostic language
    - Be encouraging about seeking support
    
    Format your response as JSON:
    {
      "interpretation_text": "Your warm, supportive interpretation here...",
      "risk_level": "low" | "moderate" | "high",
      "supportive_message": "A reassuring message about next steps"
    }
    
    Screener: {screener_title}
    Score: {score} (out of {max_score})
    Responses: {responses_summary}
  PROMPT

  # Generate AI interpretation of screener responses
  # @param screener_response [ScreenerResponse] The screener response record
  # @return [Hash] Hash with interpretation_text, risk_level, supportive_message
  def self.interpret(screener_response)
    screener = screener_response.screener
    answers = screener_response.answers_json || {}
    score = screener_response.score || calculate_score(answers, screener)
    
    max_score = calculate_max_score(screener)
    responses_summary = build_responses_summary(answers, screener)

    prompt = INTERPRETATION_PROMPT
      .gsub('{screener_title}', screener.title)
      .gsub('{score}', score.to_s)
      .gsub('{max_score}', max_score.to_s)
      .gsub('{responses_summary}', responses_summary)

    openai_service = OpenaiService.new
    
    response = openai_service.chat_completion(
      messages: [
        {
          role: 'user',
          content: prompt
        }
      ],
      system_prompt: "You are a warm, supportive mental health professional who helps parents understand assessment results in accessible, reassuring language."
    )

    # Parse JSON response
    interpretation_data = parse_interpretation_response(response[:content])
    
    # Update screener response with interpretation
    screener_response.update!(
      interpretation_text: interpretation_data[:interpretation_text],
      score: score
    )

    interpretation_data
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse interpretation JSON: #{e.message}")
    create_fallback_interpretation(score, max_score)
  rescue StandardError => e
    Rails.logger.error("Interpretation generation failed: #{e.message}")
    create_fallback_interpretation(score, max_score)
  end

  private

  def self.calculate_score(answers, screener)
    # Sum all answer values
    answers.values.sum
  end

  def self.calculate_max_score(screener)
    # Get max value from screener items
    items = screener.items_json || []
    max_option_value = items.flat_map { |item| item['options'] || [] }
                           .map { |opt| opt['value'] || 0 }
                           .max || 3
    items.length * max_option_value
  end

  def self.build_responses_summary(answers, screener)
    items = screener.items_json || []
    items.map do |item|
      answer_value = answers[item['id']]
      option = item['options']&.find { |opt| opt['value'] == answer_value }
      "#{item['text']}: #{option ? option['label'] : 'Not answered'}"
    end.join("\n")
  end

  def self.parse_interpretation_response(content)
    # Try to extract JSON from response
    json_match = content.match(/```json\s*(\{.*?\})\s*```/m) || content.match(/(\{.*\})/m)
    
    if json_match
      JSON.parse(json_match[1], symbolize_names: true)
    else
      raise JSON::ParserError, "No valid JSON found in response"
    end
  end

  def self.create_fallback_interpretation(score, max_score)
    risk_level = if score <= max_score * 0.33
      'low'
    elsif score <= max_score * 0.66
      'moderate'
    else
      'high'
    end

    {
      interpretation_text: "Thank you for completing this assessment. Your responses help us understand how you've been feeling. We'll use this information to provide the best support possible.",
      risk_level: risk_level,
      supportive_message: "Remember, this is just one tool to help us understand your situation. Our team is here to support you every step of the way."
    }
  end
end

