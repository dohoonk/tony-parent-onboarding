class FaqService
  SYSTEM_PROMPT = <<~PROMPT
    You are a warm, supportive parenting coach helping parents navigate their child's mental health journey.
    
    Your role is to:
    1. Answer questions about the onboarding process, therapy, insurance, or mental health support
    2. Provide micro-reassurance messages at stress points
    3. Use a warm, compassionate, and non-judgmental tone
    4. Keep responses concise (1-2 sentences for microcopy, 2-3 sentences for FAQs)
    5. Avoid clinical jargon unless necessary
    6. Normalize concerns and provide encouragement
    
    Tone Guidelines:
    - Be warm, compassionate, and reassuring
    - Use simple, clear language
    - Acknowledge the parent's courage in seeking help
    - Be encouraging and supportive
    - Never be dismissive or minimize concerns
    
    Important:
    - Do NOT provide medical advice or diagnoses
    - Do NOT make promises about specific outcomes
    - Focus on support, information, and reassurance
  PROMPT

  # Generate contextual FAQ answer
  # @param question [String] User's question
  # @param context [Hash] Context about current step, user actions, etc.
  # @return [String] FAQ answer
  def self.answer_question(question:, context: {})
    openai_service = OpenaiService.new
    
    context_text = build_context_text(context)
    
    messages = [
      {
        role: 'user',
        content: "#{context_text}\n\nQuestion: #{question}"
      }
    ]

    response = openai_service.chat_completion(
      messages: messages,
      system_prompt: SYSTEM_PROMPT
    )

    response[:content]
  rescue StandardError => e
    Rails.logger.error("FAQ generation failed: #{e.message}")
    "I'm here to help! Please feel free to reach out to our support team if you have any questions."
  end

  # Generate micro-reassurance message
  # @param trigger_point [String] The stress point or action that triggered this
  # @param context [Hash] Context about current step, user progress, etc.
  # @return [String] Reassuring microcopy
  def self.generate_reassurance(trigger_point:, context: {})
    openai_service = OpenaiService.new
    
    context_text = build_context_text(context)
    
    messages = [
      {
        role: 'user',
        content: "Generate a brief, warm reassurance message for a parent who is #{trigger_point}. Context: #{context_text}. Keep it to 1-2 sentences maximum."
      }
    ]

    response = openai_service.chat_completion(
      messages: messages,
      system_prompt: SYSTEM_PROMPT,
      max_tokens: 100
    )

    response[:content]
  rescue StandardError => e
    Rails.logger.error("Reassurance generation failed: #{e.message}")
    "You're doing great! We're here to support you every step of the way."
  end

  private

  def self.build_context_text(context)
    parts = []
    parts << "Current onboarding step: #{context[:step_name]}" if context[:step_name]
    parts << "Progress: #{context[:progress_percent]}% complete" if context[:progress_percent]
    parts << "Time spent: #{context[:time_spent]}" if context[:time_spent]
    parts.join(", ")
  end
end

