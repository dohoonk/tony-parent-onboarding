class IntakeSummaryService
  SUMMARY_PROMPT = <<~PROMPT
    Analyze the following intake conversation and extract structured information.
    
    Extract:
    1. **Concerns**: List the main concerns or challenges mentioned (3-5 items)
    2. **Goals**: What the parent hopes to achieve through therapy (2-4 items)
    3. **Risk Flags**: Any immediate safety concerns or urgent issues (if any)
    4. **Summary Text**: A brief 2-3 sentence summary of the conversation
    
    Format your response as JSON:
    {
      "concerns": ["concern 1", "concern 2", ...],
      "goals": ["goal 1", "goal 2", ...],
      "risk_flags": ["flag 1", ...] or [],
      "summary_text": "Brief summary here"
    }
    
    Be specific and use the parent's own words when possible. Only include risk flags if there are genuine safety concerns.
  PROMPT

  # Extract structured summary from intake conversation
  # @param session [OnboardingSession] The onboarding session
  # @return [Hash] Structured summary with concerns, goals, risk_flags, summary_text
  def self.extract_summary(session)
    messages = session.intake_messages.order(:created_at)
    conversation_text = messages.map { |m| "#{m.role}: #{m.content}" }.join("\n")

    openai_service = OpenaiService.new
    
    # Build messages for summary extraction
    summary_messages = [
      {
        role: 'user',
        content: "#{SUMMARY_PROMPT}\n\nConversation:\n#{conversation_text}"
      }
    ]

    response = openai_service.chat_completion(
      messages: summary_messages,
      system_prompt: "You are a clinical intake analyst. Extract structured information from conversations accurately and professionally."
    )

    # Parse JSON response
    summary_data = parse_summary_response(response[:content])
    
    # De-identify before storing
    deidentified_data = PhiDeidentificationService.deidentify_summary(
      OpenStruct.new(summary_data)
    )
    
    # Create or update intake summary
    summary = session.intake_summary || IntakeSummary.new(onboarding_session: session)
    summary.assign_attributes(
      concerns: deidentified_data[:concerns] || [],
      goals: deidentified_data[:goals] || [],
      risk_flags: deidentified_data[:risk_flags] || [],
      summary_text: deidentified_data[:summary_text]
    )
    
    summary.save!
    summary
  rescue JSON::ParserError => e
    Rails.logger.error("Failed to parse summary JSON: #{e.message}")
    # Fallback: create basic summary
    create_fallback_summary(session)
  rescue StandardError => e
    Rails.logger.error("Summary extraction failed: #{e.message}")
    create_fallback_summary(session)
  end

  private

  def self.parse_summary_response(content)
    # Try to extract JSON from response (may have markdown code blocks)
    json_match = content.match(/```json\s*(\{.*?\})\s*```/m) || content.match(/(\{.*\})/m)
    
    if json_match
      JSON.parse(json_match[1], symbolize_names: true)
    else
      raise JSON::ParserError, "No valid JSON found in response"
    end
  end

  def self.create_fallback_summary(session)
    messages = session.intake_messages.order(:created_at)
    user_messages = messages.where(role: 'user').pluck(:content)
    
    summary = session.intake_summary || IntakeSummary.new(onboarding_session: session)
    summary.assign_attributes(
      concerns: extract_keywords(user_messages),
      goals: [],
      risk_flags: [],
      summary_text: "Intake conversation completed. #{user_messages.count} messages exchanged."
    )
    summary.save!
    summary
  end

  def self.extract_keywords(messages)
    # Simple keyword extraction as fallback
    all_text = messages.join(' ').downcase
    concern_keywords = ['anxiety', 'depression', 'stress', 'worry', 'concern', 'struggling', 'difficulty']
    
    concerns = concern_keywords.select { |keyword| all_text.include?(keyword) }
    concerns.any? ? concerns : ['General mental health support']
  end
end

