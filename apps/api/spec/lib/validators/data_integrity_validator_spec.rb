require 'rails_helper'

RSpec.describe Validators::DataIntegrityValidator do
  let(:validator) { described_class.new }

  describe '#validate_all' do
    it 'validates all models' do
      expect(validator).to receive(:validate_therapists)
      expect(validator).to receive(:validate_organizations)
      expect(validator).to receive(:validate_contracts)
      expect(validator).to receive(:validate_credentialed_insurances)
      expect(validator).to receive(:validate_clinician_credentialed_insurances)
      expect(validator).to receive(:validate_parents)
      expect(validator).to receive(:validate_students)
      expect(validator).to receive(:validate_referrals)
      expect(validator).to receive(:validate_referral_members)
      expect(validator).to receive(:validate_kinships)
      expect(validator).to receive(:validate_memberships)
      expect(validator).to receive(:validate_availability_windows)
      expect(validator).to receive(:validate_appointments)
      expect(validator).to receive(:validate_insurance_policies)
      expect(validator).to receive(:validate_documents)
      expect(validator).to receive(:validate_questionnaires)
      expect(validator).to receive(:print_summary)

      validator.validate_all
    end
  end

  describe '#validate_therapists' do
    context 'with valid therapist' do
      let!(:therapist) { create(:therapist, email: 'test@example.com', specialties: ['anxiety'], profile_data: {}) }

      it 'validates successfully' do
        validator.send(:validate_therapists)
        expect(validator.errors).to be_empty
        expect(validator.stats[:valid_records]).to eq(1)
      end
    end

    context 'with invalid supervisor_id' do
      let!(:therapist) { create(:therapist, supervisor_id: SecureRandom.uuid) }

      it 'adds error' do
        validator.send(:validate_therapists)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('supervisor_id')
      end
    end

    context 'with missing email' do
      let!(:therapist) { create(:therapist, email: nil) }

      it 'adds error' do
        validator.send(:validate_therapists)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('email is required')
      end
    end

    context 'with invalid specialties array' do
      let!(:therapist) { create(:therapist, specialties: 'not-an-array') }

      it 'adds error' do
        validator.send(:validate_therapists)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('specialties must be an array')
      end
    end
  end

  describe '#validate_organizations' do
    context 'with valid organization' do
      let!(:org) { create(:organization, kind: 'district', config: {}) }

      it 'validates successfully' do
        validator.send(:validate_organizations)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid parent_organization_id' do
      let!(:org) { create(:organization, parent_organization_id: SecureRandom.uuid) }

      it 'adds error' do
        validator.send(:validate_organizations)
        expect(validator.errors).not_to be_empty
      end
    end

    context 'with school without parent' do
      let!(:org) { create(:organization, kind: 'school', parent_organization_id: nil) }

      it 'adds warning' do
        validator.send(:validate_organizations)
        expect(validator.warnings).not_to be_empty
        expect(validator.warnings.first).to include('school should have a parent_organization_id')
      end
    end
  end

  describe '#validate_students' do
    let!(:parent) { create(:parent) }

    context 'with valid student' do
      let!(:student) { create(:student, parent: parent, date_of_birth: 10.years.ago, system_labels: []) }

      it 'validates successfully' do
        validator.send(:validate_students)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid parent_id' do
      let!(:student) { create(:student, parent_id: SecureRandom.uuid) }

      it 'adds error' do
        validator.send(:validate_students)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('parent'))
      end
    end

    context 'with missing date_of_birth' do
      let!(:student) { create(:student, parent: parent, date_of_birth: nil) }

      it 'adds error' do
        validator.send(:validate_students)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('date_of_birth is required')
      end
    end
  end

  describe '#validate_referrals' do
    let!(:parent) { create(:parent) }
    let!(:organization) { create(:organization) }

    context 'with valid referral' do
      let!(:referral) { create(:referral, submitter: parent, organization: organization, allowed_coverage: [], care_provider_requirements: [], system_labels: []) }

      it 'validates successfully' do
        validator.send(:validate_referrals)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid submitter_id' do
      let!(:referral) { create(:referral, submitter_id: SecureRandom.uuid, organization: organization) }

      it 'adds error' do
        validator.send(:validate_referrals)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('submitter')
      end
    end

    context 'with invalid organization_id' do
      let!(:referral) { create(:referral, submitter: parent, organization_id: SecureRandom.uuid) }

      it 'adds error' do
        validator.send(:validate_referrals)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('organization')
      end
    end
  end

  describe '#validate_referral_members' do
    let!(:parent) { create(:parent) }
    let!(:student) { create(:student, parent: parent) }
    let!(:organization) { create(:organization) }
    let!(:referral) { create(:referral, submitter: parent, organization: organization) }

    context 'with valid referral member' do
      let!(:member) { create(:referral_member, referral: referral, user: student, user_type: 'Student', role: 0) }

      it 'validates successfully' do
        validator.send(:validate_referral_members)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid referral_id' do
      let!(:member) { create(:referral_member, referral_id: SecureRandom.uuid, user: student, user_type: 'Student', role: 0) }

      it 'adds error' do
        validator.send(:validate_referral_members)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('referral')
      end
    end

    context 'with invalid user_id' do
      let!(:member) { create(:referral_member, referral: referral, user_id: SecureRandom.uuid, user_type: 'Student', role: 0) }

      it 'adds error' do
        validator.send(:validate_referral_members)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('Student')
      end
    end
  end

  describe '#validate_kinships' do
    let!(:parent) { create(:parent) }
    let!(:student) { create(:student, parent: parent) }

    context 'with valid kinship' do
      let!(:kinship) { create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 1) }

      it 'validates successfully' do
        validator.send(:validate_kinships)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid user_0_id' do
      let!(:kinship) { create(:kinship, user_0_id: SecureRandom.uuid, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 1) }

      it 'adds error' do
        validator.send(:validate_kinships)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('Parent')
      end
    end

    context 'with invalid kind' do
      let!(:kinship) { create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 99) }

      it 'adds error' do
        validator.send(:validate_kinships)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('kind must be')
      end
    end
  end

  describe '#validate_memberships' do
    let!(:parent) { create(:parent) }
    let!(:organization) { create(:organization) }

    context 'with valid membership' do
      let!(:membership) { create(:membership, user: parent, user_type: 'Parent', organization: organization) }

      it 'validates successfully' do
        validator.send(:validate_memberships)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid organization_id' do
      let!(:membership) { create(:membership, user: parent, user_type: 'Parent', organization_id: SecureRandom.uuid) }

      it 'adds error' do
        validator.send(:validate_memberships)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('organization')
      end
    end
  end

  describe '#validate_availability_windows' do
    let!(:therapist) { create(:therapist) }

    context 'with valid availability window' do
      let!(:window) { create(:availability_window, owner: therapist, owner_type: 'Therapist', availability_json: { 'days' => [] }) }

      it 'validates successfully' do
        validator.send(:validate_availability_windows)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid owner_id' do
      let!(:window) { create(:availability_window, owner_id: SecureRandom.uuid, owner_type: 'Therapist', availability_json: { 'days' => [] }) }

      it 'adds error' do
        validator.send(:validate_availability_windows)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('Therapist')
      end
    end

    context 'with neither rrule nor availability_json' do
      let!(:window) { create(:availability_window, owner: therapist, owner_type: 'Therapist', rrule: nil, availability_json: nil) }

      it 'adds error' do
        validator.send(:validate_availability_windows)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('must have either rrule or availability_json')
      end
    end
  end

  describe '#validate_appointments' do
    let!(:parent) { create(:parent) }
    let!(:session) { create(:onboarding_session, parent: parent) }

    context 'with valid appointment' do
      let!(:appointment) { create(:appointment, onboarding_session: session) }

      it 'validates successfully' do
        validator.send(:validate_appointments)
        expect(validator.errors).to be_empty
      end
    end

    context 'with invalid session_id' do
      let!(:appointment) { create(:appointment, onboarding_session_id: SecureRandom.uuid) }

      it 'adds error' do
        validator.send(:validate_appointments)
        expect(validator.errors).not_to be_empty
        expect(validator.errors.first).to include('onboarding_session')
      end
    end
  end

  describe 'error and warning tracking' do
    it 'tracks errors' do
      validator.send(:add_error, 'Record 1', 'test error')
      expect(validator.errors).to include('Record 1: test error')
    end

    it 'tracks warnings' do
      validator.send(:add_warning, 'Record 1', 'test warning')
      expect(validator.warnings).to include('Record 1: test warning')
    end
  end

  describe 'statistics tracking' do
    it 'initializes stats correctly' do
      expect(validator.stats).to include(
        total_records: 0,
        valid_records: 0,
        invalid_records: 0,
        checked_relationships: 0,
        broken_relationships: 0
      )
    end
  end
end

