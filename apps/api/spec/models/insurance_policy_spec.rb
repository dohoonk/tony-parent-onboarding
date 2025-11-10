require 'rails_helper'

RSpec.describe InsurancePolicy, type: :model do
  describe 'associations' do
    it { should belong_to(:onboarding_session) }
  end

  describe 'validations' do
    it { should validate_presence_of(:payer_name) }
    it { should validate_presence_of(:member_id) }
    it { should validate_uniqueness_of(:onboarding_session_id) }
  end

  describe 'encryption' do
    let(:parent) { Parent.create!(email: 'test@example.com', first_name: 'John', last_name: 'Doe') }
    let(:student) { Student.create!(parent: parent, first_name: 'Jane', last_name: 'Doe', date_of_birth: 10.years.ago) }
    let(:session) { OnboardingSession.create!(parent: parent, student: student) }

    it 'encrypts member_id' do
      policy = InsurancePolicy.create!(
        onboarding_session: session,
        payer_name: 'Blue Cross',
        member_id: 'ABC123456'
      )

      # Check that the database value is encrypted (not plaintext)
      raw_value = ActiveRecord::Base.connection.execute(
        "SELECT member_id FROM insurance_policies WHERE id = '#{policy.id}'"
      ).first['member_id']

      expect(raw_value).not_to eq('ABC123456')
      expect(policy.member_id).to eq('ABC123456')
    end

    it 'encrypts group_number' do
      policy = InsurancePolicy.create!(
        onboarding_session: session,
        payer_name: 'Blue Cross',
        member_id: 'ABC123456',
        group_number: 'GRP789'
      )

      raw_value = ActiveRecord::Base.connection.execute(
        "SELECT group_number FROM insurance_policies WHERE id = '#{policy.id}'"
      ).first['group_number']

      expect(raw_value).not_to eq('GRP789')
      expect(policy.group_number).to eq('GRP789')
    end
  end

  describe 'callbacks' do
    let(:parent) { Parent.create!(email: 'test@example.com', first_name: 'John', last_name: 'Doe') }
    let(:student) { Student.create!(parent: parent, first_name: 'Jane', last_name: 'Doe', date_of_birth: 10.years.ago) }
    let(:session) { OnboardingSession.create!(parent: parent, student: student) }

    it 'normalizes member_id' do
      policy = InsurancePolicy.create!(
        onboarding_session: session,
        payer_name: 'Blue Cross',
        member_id: '  abc123  '
      )

      expect(policy.member_id).to eq('ABC123')
    end
  end
end

