module Types
  class QueryType < Types::BaseObject
    description "The query root of this schema"

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :health_check, String, null: false,
      description: "API health check endpoint"

    field :onboarding_session, resolver: Queries::OnboardingSession
    field :available_screeners, resolver: Queries::AvailableScreeners
    field :faq_answer, resolver: Queries::FaqAnswer
    field :reassurance_message, resolver: Queries::ReassuranceMessage
    field :therapist, resolver: Queries::Therapist
    field :therapists, resolver: Queries::Therapists
    field :organization, resolver: Queries::Organization
    field :organizations, resolver: Queries::Organizations
    field :contract, resolver: Queries::Contract
    field :contracts, resolver: Queries::Contracts

    def health_check
      "OK"
    end
  end
end

