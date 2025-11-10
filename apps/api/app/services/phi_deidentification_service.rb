class PhiDeidentificationService
  # Common PHI patterns to detect and redact
  PHI_PATTERNS = {
    ssn: /\b\d{3}-\d{2}-\d{4}\b/,
    phone: /\b\d{3}[-.\s]?\d{3}[-.\s]?\d{4}\b/,
    email: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/,
    date_of_birth: /\b\d{1,2}\/\d{1,2}\/\d{2,4}\b/,
    medical_record: /\bMRN[:\s]?\d+\b/i,
    insurance_id: /\b(?:member|policy|subscriber)[\s#:]*\d+\b/i
  }.freeze

  # Pseudonym generator
  PSEUDONYMS = {
    names: ['Alex', 'Jordan', 'Taylor', 'Casey', 'Morgan', 'Riley', 'Quinn', 'Avery'],
    places: ['Springfield', 'Riverside', 'Oakwood', 'Maple', 'Hillcrest']
  }.freeze

  # De-identify text by replacing PHI with pseudonyms or placeholders
  # @param text [String] Text containing potential PHI
  # @param use_pseudonyms [Boolean] Whether to use pseudonyms (true) or placeholders (false)
  # @return [Hash] Hash with deidentified_text and phi_detected array
  def self.deidentify(text, use_pseudonyms: true)
    deidentified = text.dup
    phi_detected = []

    # Detect and replace PHI
    PHI_PATTERNS.each do |type, pattern|
      matches = text.scan(pattern)
      next if matches.empty?

      phi_detected << { type: type, count: matches.length }
      
      deidentified.gsub!(pattern) do |match|
        if use_pseudonyms
          generate_pseudonym(type)
        else
          "[#{type.to_s.upcase}_REDACTED]"
        end
      end
    end

    # Detect and replace names (simple heuristic - capitalized words that might be names)
    # This is a basic implementation - in production, use NER (Named Entity Recognition)
    name_pattern = /\b[A-Z][a-z]+(?:\s+[A-Z][a-z]+)+\b/
    potential_names = text.scan(name_pattern).reject do |match|
      # Exclude common non-name words
      %w[The This That These Those].include?(match.split.first)
    end

    if potential_names.any?
      phi_detected << { type: :name, count: potential_names.length }
      potential_names.each do |name|
        replacement = use_pseudonyms ? PSEUDONYMS[:names].sample : '[NAME_REDACTED]'
        deidentified.gsub!(/\b#{Regexp.escape(name)}\b/, replacement)
      end
    end

    {
      deidentified_text: deidentified,
      phi_detected: phi_detected
    }
  end

  # De-identify intake messages before storing
  # @param messages [ActiveRecord::Relation] Collection of IntakeMessage records
  # @return [Array<Hash>] Array of de-identified message hashes
  def self.deidentify_messages(messages)
    messages.map do |message|
      result = deidentify(message.content, use_pseudonyms: true)
      {
        id: message.id,
        role: message.role,
        content: result[:deidentified_text],
        phi_detected: result[:phi_detected]
      }
    end
  end

  # De-identify summary before storing
  # @param summary [IntakeSummary] Intake summary record
  # @return [Hash] De-identified summary data
  def self.deidentify_summary(summary)
    concerns = summary.concerns.map { |c| deidentify(c, use_pseudonyms: true)[:deidentified_text] }
    goals = summary.goals.map { |g| deidentify(g, use_pseudonyms: true)[:deidentified_text] }
    risk_flags = summary.risk_flags.map { |r| deidentify(r, use_pseudonyms: true)[:deidentified_text] }
    summary_text = deidentify(summary.summary_text || '', use_pseudonyms: true)[:deidentified_text]

    {
      concerns: concerns,
      goals: goals,
      risk_flags: risk_flags,
      summary_text: summary_text
    }
  end

  private

  def self.generate_pseudonym(type)
    case type
    when :name
      PSEUDONYMS[:names].sample
    when :phone
      "(555) 000-0000"
    when :email
      "user#{rand(1000..9999)}@example.com"
    when :ssn
      "XXX-XX-XXXX"
    when :date_of_birth
      "[DATE]"
    else
      "[REDACTED]"
    end
  end
end

