module Mutations
  class ConfirmInsurance < BaseMutation
    description "Confirm insurance policy details"

    argument :input, Types::Inputs::ConfirmInsuranceInput, required: true

    field :policy, Types::InsurancePolicyType, null: false
    field :errors, [String], null: false

    def resolve(input:)
      parent = context[:current_user]
      
      unless parent
        return { policy: nil, errors: ["Authentication required"] }
      end

      session = parent.onboarding_sessions.find_by(id: input.session_id)
      
      unless session
        return { policy: nil, errors: ["Session not found"] }
      end

      # Create or update insurance policy
      policy = session.insurance_policy || InsurancePolicy.new(onboarding_session: session)
      
      policy.assign_attributes(
        payer_name: input.payer_name,
        member_id: input.member_id,
        group_number: input.group_number,
        plan_type: input.plan_type,
        subscriber_name: input.subscriber_name
      )

      if policy.save
        # Log audit trail
        AuditLog.log_access(
          actor: parent,
          action: policy.previously_new_record? ? 'write' : 'update',
          entity: policy,
          after: policy.attributes
        )

        # TODO: Trigger insurance verification
        # InsuranceVerificationJob.perform_later(policy.id)

        { policy: policy, errors: [] }
      else
        { policy: nil, errors: policy.errors.full_messages }
      end
    end
  end
end

