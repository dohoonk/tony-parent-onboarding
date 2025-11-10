module Queries
  class Therapists < BaseQuery
    description "List all therapists with optional filtering"

    argument :state, String, required: false, description: "Filter by primary state"
    argument :employment_type, String, required: false, description: "Filter by employment type"
    argument :clinical_role, String, required: false, description: "Filter by clinical role"
    argument :specialty, String, required: false, description: "Filter by specialty"
    argument :language, String, required: false, description: "Filter by language"
    argument :licensed_in_state, String, required: false, description: "Filter by licensed state"
    argument :active_only, Boolean, required: false, default_value: true, description: "Only return active therapists"
    argument :with_capacity, Boolean, required: false, description: "Only return therapists with available capacity"
    argument :limit, Integer, required: false, default_value: 50, description: "Maximum number of results"
    argument :offset, Integer, required: false, default_value: 0, description: "Offset for pagination"

    type [Types::TherapistType], null: false

    def resolve(
      state: nil,
      employment_type: nil,
      clinical_role: nil,
      specialty: nil,
      language: nil,
      licensed_in_state: nil,
      active_only: true,
      with_capacity: false,
      limit: 50,
      offset: 0
    )
      scope = ::Therapist.all

      scope = scope.active if active_only
      scope = scope.by_state(state) if state.present?
      scope = scope.by_employment_type(employment_type) if employment_type.present?
      scope = scope.by_clinical_role(clinical_role) if clinical_role.present?
      scope = scope.with_specialty(specialty) if specialty.present?
      scope = scope.with_language(language) if language.present?
      scope = scope.licensed_in_state(licensed_in_state) if licensed_in_state.present?
      scope = scope.available if with_capacity

      scope.limit(limit).offset(offset)
    end
  end
end

