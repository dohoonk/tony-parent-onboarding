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
  def self.match(student:, availability_window:, insurance_policy: nil, limit: 4)
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
        insurance_policy: insurance_policy
      )
      
      {
        therapist: therapist,
        score: score[:total],
        rationale: score[:rationale],
        match_details: score[:details]
      }
    end

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

  def self.calculate_match_score(therapist:, student:, availability_window:, insurance_policy:)
    score = 0
    rationale_parts = []
    details = {}

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
    if therapist.care_languages.include?('en') || therapist.care_languages.include?('eng')
      score += 10
      rationale_parts << "Language: English"
      details[:language_match] = true
    else
      details[:language_match] = false
    end

    # Capacity match (10 points max) - prefer therapists with more availability
    if therapist.has_capacity?
      capacity_score = ((therapist.capacity_available.to_f / [therapist.capacity_total, 1].max) * 10).round
      score += capacity_score
      rationale_parts << "Capacity: #{therapist.capacity_available} slots available"
      details[:capacity_available] = therapist.capacity_available
    else
      details[:capacity_available] = 0
    end

    {
      total: score,
      rationale: rationale_parts.join('; '),
      details: details
    }
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
