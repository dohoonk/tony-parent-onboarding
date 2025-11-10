module Types
  class ReferralType < Types::BaseObject
    description "A referral for mental health services"

    field :id, ID, null: false
    field :submitter_id, ID, null: false
    field :organization_id, ID, null: false
    field :contract_id, ID, null: true
    field :intake_id, ID, null: true
    field :care_provider_id, ID, null: true
    
    # Basic information
    field :service_kind, Integer, null: true
    field :concerns, String, null: true
    field :data, GraphQL::Types::JSON, null: true
    
    # Contract and terms
    field :terms_kind, Integer, null: true
    field :appointment_kind, Integer, null: true
    field :planned_sessions, Integer, null: true
    field :initial_scheduled_sessions, Integer, null: true
    
    # Coverage and payment
    field :collect_coverage, Boolean, null: false
    field :allowed_coverage, [String], null: false
    field :collection_rule, Integer, null: true
    field :self_responsibility_required, Boolean, null: false
    
    # Care provider requirements
    field :care_provider_requirements, [String], null: false
    
    # Status timestamps
    field :referred_at, GraphQL::Types::ISO8601DateTime, null: true
    field :ready_for_scheduling_at, GraphQL::Types::ISO8601DateTime, null: true
    field :scheduled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :onboarding_completed_at, GraphQL::Types::ISO8601DateTime, null: true
    field :enrolled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :disenrolled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :request_rejected_at, GraphQL::Types::ISO8601DateTime, null: true
    field :excluded_at, GraphQL::Types::ISO8601DateTime, null: true
    
    # Additional fields
    field :system_labels, [String], null: false
    field :tzdb, String, null: true
    field :notes, String, null: true
    field :disenrollment_category, String, null: true
    field :zendesk_ticket_id, String, null: true
    field :market_id, ID, null: true
    
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :submitter, Types::ParentType, null: false
    field :organization, Types::OrganizationType, null: false
    field :contract, Types::ContractType, null: true
    field :care_provider, Types::TherapistType, null: true
    field :referral_members, [Types::ReferralMemberType], null: false

    # Computed fields
    field :status, String, null: false
    field :referred, Boolean, null: false
    field :ready_for_scheduling, Boolean, null: false
    field :scheduled, Boolean, null: false
    field :enrolled, Boolean, null: false
    field :disenrolled, Boolean, null: false
    field :rejected, Boolean, null: false
    field :students, [Types::StudentType], null: false
    field :parents, [Types::ParentType], null: false

    # Computed field resolvers
    def status
      object.status
    end

    def referred
      object.referred?
    end

    def ready_for_scheduling
      object.ready_for_scheduling?
    end

    def scheduled
      object.scheduled?
    end

    def enrolled
      object.enrolled?
    end

    def disenrolled
      object.disenrolled?
    end

    def rejected
      object.rejected?
    end

    def students
      object.students
    end

    def parents
      object.parents
    end
  end
end

