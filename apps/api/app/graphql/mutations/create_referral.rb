module Mutations
  class CreateReferral < BaseMutation
    description "Create a new referral for mental health services"

    argument :input, Types::Inputs::CreateReferralInput, required: true

    field :referral, Types::ReferralType, null: true
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { referral: nil, errors: ["Authentication required"] }
      end

      # Find the student
      student = parent.students.find_by(id: input.student_id)
      unless student
        return { referral: nil, errors: ["Student not found"] }
      end

      # Find the organization
      organization = Organization.find_by(id: input.organization_id)
      unless organization
        return { referral: nil, errors: ["Organization not found"] }
      end

      # Check authorization - parent can only create referrals for their own students
      unless parent.can?(:manage_own_onboarding)
        return { referral: nil, errors: ["Not authorized to create referrals"] }
      end

      # Build referral
      referral = Referral.new(
        submitter: parent,
        organization: organization,
        service_kind: input.service_kind,
        concerns: input.concerns,
        contract_id: input.contract_id,
        terms_kind: input.terms_kind,
        appointment_kind: input.appointment_kind,
        planned_sessions: input.planned_sessions || 12,
        collect_coverage: input.collect_coverage,
        allowed_coverage: input.allowed_coverage || [],
        collection_rule: input.collection_rule,
        self_responsibility_required: input.self_responsibility_required,
        care_provider_requirements: input.care_provider_requirements || [],
        tzdb: input.tzdb || 'America/Los_Angeles',
        data: input.data || {}
      )

      if referral.save
        # Create referral member for the student
        ReferralMember.create!(
          referral: referral,
          user: student,
          user_type: 'Student',
          role: 0,
          data: {}
        )

        # Mark as referred
        referral.mark_referred!

        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: 'write',
          entity: referral,
          after: referral.attributes
        )

        { referral: referral, errors: [] }
      else
        { referral: nil, errors: referral.errors.full_messages }
      end
    end
  end
end

