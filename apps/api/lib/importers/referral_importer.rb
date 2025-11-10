module Importers
  class ReferralImporter < BaseCsvImporter
    def initialize(csv_path = nil)
      csv_path ||= Rails.root.join('../../devdocs/referrals.csv')
      super(csv_path, Referral)
    end

    protected

    def build_attributes(row)
      # Find required associations
      submitter = find_record(Parent, row['submitter_id'], required: true)
      organization = find_record(Organization, row['organization_id'], required: true)
      contract = find_record(Contract, row['contract_id'], required: false)
      care_provider = find_record(Therapist, row['care_provider_id'], required: false)
      
      # Parse arrays
      allowed_coverage = parse_array_field(row, 'allowed_coverage', default: [])
      care_provider_requirements = parse_array_field(row, 'care_provider_requirements', default: [])
      system_labels = parse_array_field(row, 'system_labels', default: [])
      
      # Parse JSONB fields
      data = parse_json_field(row, 'data', default: {})
      
      {
        id: row['id'],
        submitter_id: submitter.id,
        organization_id: organization.id,
        contract_id: contract&.id,
        care_provider_id: care_provider&.id,
        service_kind: parse_integer(row, 'service_kind', default: 0),
        concerns: row['concerns'].presence,
        data: data,
        terms_kind: parse_integer(row, 'terms_kind'),
        appointment_kind: parse_integer(row, 'appointment_kind'),
        planned_sessions: parse_integer(row, 'planned_sessions', default: 12),
        collect_coverage: parse_boolean(row, 'collect_coverage', default: true),
        allowed_coverage: allowed_coverage,
        collection_rule: parse_integer(row, 'collection_rule'),
        self_responsibility_required: parse_boolean(row, 'self_responsibility_required', default: false),
        care_provider_requirements: care_provider_requirements,
        referred_at: parse_timestamp(row, 'referred_at'),
        ready_for_scheduling_at: parse_timestamp(row, 'ready_for_scheduling_at'),
        scheduled_at: parse_timestamp(row, 'scheduled_at'),
        onboarding_completed_at: parse_timestamp(row, 'onboarding_completed_at'),
        enrolled_at: parse_timestamp(row, 'enrolled_at'),
        disenrolled_at: parse_timestamp(row, 'disenrolled_at'),
        disenrollment_category: row['disenrollment_category'].presence,
        request_rejected_at: parse_timestamp(row, 'request_rejected_at'),
        notes: row['notes'].presence,
        intake_id: row['intake_id'].presence,
        tzdb: row['tzdb'].presence || 'America/Los_Angeles',
        system_labels: system_labels,
        initial_scheduled_sessions: parse_integer(row, 'initial_scheduled_sessions', default: 0),
        zendesk_ticket_id: row['zendesk_ticket_id'].presence,
        created_at: parse_timestamp(row, 'created_at') || Time.current,
        updated_at: parse_timestamp(row, 'updated_at') || Time.current
      }
    end
  end
end

