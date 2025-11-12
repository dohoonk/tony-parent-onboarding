class TherapistMatchingService
  # Matching heuristic based on:
  # - Insurance credentialing
  # - Language preference
  # - Availability windows (day/time matching)
  # - Current clinician capacity
  # - Geographic location (state)
  # - Specialties

  # Match therapists for a student
  # @param student [Student] The student seeking therapy
  # @param availability_window [AvailabilityWindow] Preferred time slot (patient availability)
  # @param insurance_policy [InsurancePolicy] Optional insurance policy for network matching
  # @param limit [Integer] Maximum number of matches to return
  # @return [Array<Hash>] Array of matched therapists with scores and rationale
  def self.match(student:, availability_window:, insurance_policy: nil, preference: nil, limit: 4)
    # Start with active therapists with capacity
    base_scope = Therapist.active.with_capacity

    # Filter by state if student has location info
    # (Assuming student or parent has state info - may need to add this)
    
    # Filter by insurance network if insurance provided
    if insurance_policy&.insurance_company.present?
      insurance_name = insurance_policy.insurance_company
      # Find credentialed insurance by name
      credentialed_insurance = CredentialedInsurance.find_by(name: insurance_name)
      
      if credentialed_insurance&.in_network?
        # Only match therapists credentialed with this insurance
        therapist_ids = ClinicianCredentialedInsurance
          .where(credentialed_insurance: credentialed_insurance)
          .pluck(:care_provider_profile_id)
        base_scope = base_scope.where(id: therapist_ids)
      end
    end

    # Get all candidate therapists
    candidates = base_scope.limit(50) # Limit initial candidates for performance

    # Score each therapist
    scored_therapists = candidates.map do |therapist|
      score = calculate_match_score(
        therapist: therapist,
        student: student,
        availability_window: availability_window,
        insurance_policy: insurance_policy,
        preference: preference,
        student_language: student.language
      )
      availability_match_count = score[:details]&.dig(:availability_match, :match_count).to_i
      next nil if availability_match_count.zero?
      
      {
        therapist: therapist,
        score: score[:total],
        rationale: score[:rationale],
        match_details: score[:details]
      }
    end.compact

    # Sort by score and return top matches
    scored_therapists
      .select { |t| t[:score] > 0 } # Only return therapists with some match
      .sort_by { |t| -t[:score] }
      .first(limit)
      .map do |match|
        therapist = match[:therapist]
        {
          id: therapist.id,
          name: therapist.display_name,
          email: therapist.email,
          phone: therapist.phone,
          languages: therapist.care_languages,
          specialties: therapist.specialties,
          modalities: therapist.modalities,
          bio: therapist.bio,
          capacity_available: therapist.capacity_available,
          capacity_utilization: therapist.capacity_utilization_percentage,
          match_score: match[:score],
          match_rationale: match[:rationale],
          match_details: match[:match_details]
        }
      end
  end

  private

  def self.calculate_match_score(therapist:, student:, availability_window:, insurance_policy:, preference:, student_language:)
    score = 0
    rationale_parts = []
    details = {}
    student_language ||= student&.language

    # Insurance network match (50 points max) - highest priority
    if insurance_policy&.insurance_company.present?
      insurance_name = insurance_policy.insurance_company
      credentialed_insurance = CredentialedInsurance.find_by(name: insurance_name)
      
      if credentialed_insurance
        is_credentialed = therapist.credentialed_insurances.include?(credentialed_insurance)
        if is_credentialed && credentialed_insurance.in_network?
          score += 50
          rationale_parts << "In-network with #{insurance_name}"
          details[:insurance_match] = true
        elsif is_credentialed && credentialed_insurance.out_of_network?
          score += 25
          rationale_parts << "Out-of-network with #{insurance_name}"
          details[:insurance_match] = 'out_of_network'
        else
          details[:insurance_match] = false
        end
      else
        details[:insurance_match] = 'unknown_insurance'
      end
    else
      details[:insurance_match] = 'no_insurance_provided'
    end

    # Availability match (30 points max)
    availability_score = calculate_availability_match(therapist, availability_window)
    score += availability_score[:points]
    rationale_parts << availability_score[:rationale]
    details[:availability_match] = availability_score[:details]

    # Language match (10 points max)
    # Check if therapist speaks student's preferred language (if available)
    # For now, give points for English (most common)
    language_score = calculate_language_match(
      therapist: therapist,
      student_language: student_language,
      preference: preference
    )
    score += language_score[:points]
    rationale_parts << language_score[:rationale] if language_score[:rationale].present?
    details[:language_match] = language_score[:details]

    # Capacity match (10 points max) - prefer therapists with more availability
    if therapist.has_capacity?
      capacity_score = ((therapist.capacity_available.to_f / [therapist.capacity_total, 1].max) * 10).round
      score += capacity_score
      rationale_parts << "Capacity: #{therapist.capacity_available} slots available"
      details[:capacity_available] = therapist.capacity_available
    else
      details[:capacity_available] = 0
    end

    preference_score = calculate_preference_match(
      therapist: therapist,
      preference: preference
    )
    score += preference_score[:points]
    rationale_parts << preference_score[:rationale] if preference_score[:rationale].present?
    details[:preference_match] = preference_score[:details]

    score = [[score, 0].max, 100].min

    {
      total: score,
      rationale: rationale_parts.join('; '),
      details: details
    }
  end

  def self.calculate_language_match(therapist:, student_language:, preference:)
    normalized_languages = Array(therapist.care_languages).map { |lang| lang&.downcase }.compact
    requested_language = student_language&.downcase
    requested_language = nil if requested_language.blank? || requested_language == 'other'

    prefers_specific_language = preference == 'language'

    if requested_language && normalized_languages.include?(requested_language)
      points = 10
      rationale = "Speaks #{requested_language.titleize}"
      details = { matched: true, requested: requested_language }
    elsif prefers_specific_language
      if requested_language.nil?
        points = 0
        rationale = nil
        details = { matched: false, requested: requested_language }
      else
      points = -15
      rationale = "Does not speak requested language"
      details = { matched: false, requested: requested_language }
      end
    elsif normalized_languages.include?('en') || normalized_languages.include?('eng')
      points = 8
      rationale = "Language: English"
      details = { matched: true, requested: 'english' }
    else
      points = 0
      rationale = nil
      details = { matched: false, requested: requested_language }
    end

    { points: points, rationale: rationale, details: details }
  end

  def self.calculate_preference_match(therapist:, preference:)
    return { points: 0, rationale: nil, details: { applied: false } } if preference.blank? || preference == 'no-preference' || preference == 'language'

    desired_gender = case preference
                     when 'female' then 'female'
                     when 'male' then 'male'
                     else nil
                     end

    return { points: 0, rationale: nil, details: { applied: false } } unless desired_gender

    therapist_gender = [
      therapist.standardized_gender,
      therapist.legal_gender,
      therapist.self_gender
    ].compact.map(&:downcase).find { |g| %w[female male].include?(g) }

    if therapist_gender == desired_gender
      {
        points: 10,
        rationale: "Matches #{desired_gender} preference",
        details: { applied: true, requested: desired_gender, matched: true, therapist_gender: therapist_gender }
      }
    else
      {
        points: -15,
        rationale: "Does not match #{desired_gender} preference",
        details: { applied: true, requested: desired_gender, matched: false, therapist_gender: therapist_gender }
      }
    end
  end

  def self.calculate_availability_match(therapist, patient_availability_window)
    # Get therapist's availability windows
    therapist_availabilities = AvailabilityWindow
      .where(owner_type: 'Therapist', owner_id: therapist.id)
      .active
      .with_json_format

    return { points: 0, rationale: 'No availability data', details: {} } if therapist_availabilities.empty?

    # Extract patient's preferred days and times from availability_window
    patient_days = []
    patient_time_blocks = []

    if patient_availability_window.uses_json_format?
      patient_days = patient_availability_window.availability_days.map { |d| d['day'] }
      patient_availability_window.availability_days.each do |day|
        day['time_blocks']&.each do |block|
          patient_time_blocks << {
            day: day['day'],
            start: block['start'],
            duration: block['duration'] || 60
          }
        end
      end
    end

    return { points: 0, rationale: 'No patient availability specified', details: {} } if patient_days.empty?

    # Check for overlapping availability
    matches = []
    therapist_availabilities.each do |therapist_avail|
      next unless therapist_avail.uses_json_format?

      therapist_avail.availability_days.each do |therapist_day|
        day_name = therapist_day['day']
        next unless patient_days.include?(day_name)

        therapist_day['time_blocks']&.each do |therapist_block|
          patient_time_blocks.each do |patient_block|
            next unless patient_block[:day] == day_name

            # Check if time blocks overlap
            if time_blocks_overlap?(
              therapist_block['start'],
              therapist_block['duration'] || 60,
              patient_block[:start],
              patient_block[:duration]
            )
              matches << {
                day: day_name,
                therapist_start: therapist_block['start'],
                patient_start: patient_block[:start]
              }
            end
          end
        end
      end
    end

    if matches.any?
      match_count = matches.length
      points = [match_count * 5, 30].min # 5 points per match, max 30
      {
        points: points,
        rationale: "Available on #{matches.map { |m| m[:day] }.uniq.join(', ')} (#{match_count} time slots)",
        details: { matches: matches, match_count: match_count }
      }
    else
      {
        points: 0,
        rationale: 'No overlapping availability',
        details: { matches: [] }
      }
    end
  end

  def self.time_blocks_overlap?(start1, duration1, start2, duration2)
    time1_start = parse_time_to_seconds(start1)
    time1_end = time1_start + duration1 * 60
    time2_start = parse_time_to_seconds(start2)
    time2_end = time2_start + duration2 * 60

    # Check if blocks overlap
    time1_start < time2_end && time2_start < time1_end
  end

  def self.parse_time_to_seconds(time_string)
    parts = time_string.split(':').map(&:to_i)
    parts[0] * 3600 + parts[1] * 60 + (parts[2] || 0)
  end
end
