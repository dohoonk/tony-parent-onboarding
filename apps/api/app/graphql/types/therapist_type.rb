module Types
  class TherapistType < Types::BaseObject
    description "A therapist or clinician"

    field :id, ID, null: false
    field :healthie_id, String, null: true
    field :email, String, null: true
    field :phone, String, null: true
    field :first_name, String, null: true
    field :middle_name, String, null: true
    field :last_name, String, null: true
    field :preferred_name, String, null: true
    field :preferred_pronoun, String, null: true
    field :title, String, null: true
    field :birthdate, GraphQL::Types::ISO8601Date, null: true
    field :preferred_language, String, null: true
    
    # Demographics
    field :legal_gender, String, null: true
    field :standardized_gender, String, null: true
    field :self_gender, String, null: true
    field :gender_identity, String, null: true
    field :ethnicity, String, null: true
    field :ethnicity_and_demographics, [String], null: true
    field :primary_ethnicity, String, null: true
    field :primary_ethnicity_code, String, null: true
    field :primary_race, String, null: true
    field :primary_race_code, String, null: true
    field :religions, [String], null: true
    field :standardized_sexual_orientation, String, null: true
    field :self_sexual_orientation, String, null: true
    field :sexual_orientation, String, null: true
    field :sexual_orientation_code, String, null: true
    
    # Professional Information
    field :npi_number, String, null: true
    field :licenses, [String], null: true
    field :licensed_states, [String], null: true
    field :primary_state, String, null: true
    field :states_active, [String], null: true
    field :specialties, [String], null: true
    field :modalities, [String], null: true
    field :care_languages, [String], null: true
    field :employment_type, String, null: true
    field :clinical_role, String, null: true
    field :care_provider_role, String, null: true
    field :care_provider_status, String, null: true
    field :clinical_associate, Boolean, null: false
    field :is_super_admin, Boolean, null: false
    
    # Bio and Profile
    field :bio, String, null: true
    field :profile_data, GraphQL::Types::JSON, null: true
    
    # Supervision
    field :supervisor_id, ID, null: true
    field :associate_supervisor_id, ID, null: true
    field :supervisor, TherapistType, null: true
    field :associate_supervisor, TherapistType, null: true
    field :supervisees, [TherapistType], null: true
    field :associate_supervisees, [TherapistType], null: true
    
    # Capacity Management
    field :capacity_total, Integer, null: false
    field :capacity_filled, Integer, null: false
    field :capacity_available, Integer, null: false
    field :capacity_total_daybreak, Integer, null: false
    field :capacity_filled_daybreak, Integer, null: false
    field :capacity_available_daybreak, Integer, null: false
    field :capacity_total_kaiser, Integer, null: false
    field :capacity_filled_kaiser, Integer, null: false
    field :capacity_available_kaiser, Integer, null: false
    
    # Computed fields
    field :full_name, String, null: false
    field :display_name, String, null: false
    field :capacity_utilization_percentage, Float, null: false
    field :has_capacity, Boolean, null: false
    field :has_capacity_for_daybreak, Boolean, null: false
    field :has_capacity_for_kaiser, Boolean, null: false
    field :is_supervisor, Boolean, null: false
    field :is_supervised, Boolean, null: false
    
    # Status and Metadata
    field :account_status, String, null: true
    field :system_labels, [String], null: true
    field :active, Boolean, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Computed field resolvers
    def full_name
      object.full_name
    end

    def display_name
      object.display_name
    end

    def capacity_utilization_percentage
      object.capacity_utilization_percentage
    end

    def has_capacity
      object.has_capacity?
    end

    def has_capacity_for_daybreak
      object.has_capacity_for_daybreak?
    end

    def has_capacity_for_kaiser
      object.has_capacity_for_kaiser?
    end

    def is_supervisor
      object.is_supervisor?
    end

    def is_supervised
      object.is_supervised?
    end
  end
end

