class TherapistMatchingService
  # Matching heuristic based on:
  # - Language preference
  # - Student grade/age
  # - Availability windows
  # - Current clinician load

  # Match therapists for a student
  # @param student [Student] The student seeking therapy
  # @param availability_window [AvailabilityWindow] Preferred time slot
  # @param limit [Integer] Maximum number of matches to return
  # @return [Array<Hash>] Array of matched therapists with scores and rationale
  def self.match(student:, availability_window:, limit: 4)
    # In a real implementation, this would query a therapists/clinicians table
    # For now, we'll return mock data with matching logic
    
    # Mock therapist data - in production, this comes from database
    all_therapists = [
      {
        id: 1,
        name: 'Dr. Sarah Johnson',
        languages: ['English', 'Spanish'],
        specialties: ['Anxiety', 'Depression', 'ADHD'],
        grade_range: [5, 12],
        bio: 'Experienced child therapist specializing in anxiety and depression.',
        current_load: 0.7
      },
      {
        id: 2,
        name: 'Dr. Michael Chen',
        languages: ['English', 'Mandarin'],
        specialties: ['Anxiety', 'Trauma'],
        grade_range: [3, 10],
        bio: 'Bilingual therapist with expertise in trauma-informed care.',
        current_load: 0.5
      },
      {
        id: 3,
        name: 'Dr. Emily Rodriguez',
        languages: ['English', 'Spanish'],
        specialties: ['ADHD', 'Behavioral Issues'],
        grade_range: [1, 8],
        bio: 'Specialist in ADHD and behavioral interventions for younger children.',
        current_load: 0.6
      },
      {
        id: 4,
        name: 'Dr. James Wilson',
        languages: ['English'],
        specialties: ['Depression', 'Anxiety', 'Trauma'],
        grade_range: [6, 12],
        bio: 'Teen-focused therapist with expertise in depression and trauma.',
        current_load: 0.8
      }
    ]

    # Calculate student grade (approximate from age/DOB)
    student_grade = estimate_grade(student.date_of_birth)
    
    # Score each therapist
    scored_therapists = all_therapists.map do |therapist|
      score = calculate_match_score(
        therapist: therapist,
        student: student,
        student_grade: student_grade,
        availability_window: availability_window
      )
      
      {
        therapist: therapist,
        score: score[:total],
        rationale: score[:rationale]
      }
    end

    # Sort by score and return top matches
    scored_therapists
      .sort_by { |t| -t[:score] }
      .first(limit)
      .map do |match|
        {
          id: match[:therapist][:id],
          name: match[:therapist][:name],
          languages: match[:therapist][:languages],
          specialties: match[:therapist][:specialties],
          bio: match[:therapist][:bio],
          match_score: match[:score],
          match_rationale: match[:rationale]
        }
      end
  end

  private

  def self.estimate_grade(date_of_birth)
    return 5 unless date_of_birth # Default to middle school

    age = ((Time.current - date_of_birth.to_time) / 1.year).floor
    
    # Rough grade estimation (US system)
    case age
    when 5..6 then 0  # Kindergarten
    when 7..8 then 2  # 2nd grade
    when 9..10 then 4 # 4th grade
    when 11..12 then 6 # 6th grade
    when 13..14 then 8 # 8th grade
    when 15..16 then 10 # 10th grade
    when 17..18 then 12 # 12th grade
    else 5 # Default to middle school
    end
  end

  def self.calculate_match_score(therapist:, student:, student_grade:, availability_window:)
    score = 0
    rationale_parts = []

    # Language match (40 points max)
    # In production, check student's preferred language
    if therapist[:languages].include?('English')
      score += 40
      rationale_parts << "Language match: English"
    end

    # Grade/age match (30 points max)
    if student_grade.between?(therapist[:grade_range][0], therapist[:grade_range][1])
      score += 30
      rationale_parts << "Age-appropriate: Grade #{student_grade} within range"
    else
      score += 10 # Partial match
      rationale_parts << "Age range: Close match"
    end

    # Availability match (20 points max)
    # In production, check therapist's actual availability
    score += 20
    rationale_parts << "Available during requested time"

    # Load factor (10 points max) - prefer therapists with lower load
    load_score = ((1 - therapist[:current_load]) * 10).round
    score += load_score
    rationale_parts << "Current availability: #{((1 - therapist[:current_load]) * 100).round}%"

    {
      total: score,
      rationale: rationale_parts.join('; ')
    }
  end
end

