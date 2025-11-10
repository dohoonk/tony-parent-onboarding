require 'rails_helper'

RSpec.describe Referral, type: :model do
  describe 'associations' do
    it { should belong_to(:submitter).class_name('Parent') }
    it { should belong_to(:organization) }
    it { should belong_to(:contract).optional }
    it { should belong_to(:care_provider).class_name('Therapist').optional }
    it { should have_many(:referral_members).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:referral) }
    
    it { should validate_presence_of(:submitter_id) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:service_kind) }
    it { should validate_presence_of(:terms_kind) }
    it { should validate_presence_of(:appointment_kind) }
  end

  describe '#status' do
    it 'returns disenrolled if disenrolled_at is present' do
      referral = build(:referral, disenrolled_at: Time.current)
      expect(referral.status).to eq('disenrolled')
    end

    it 'returns enrolled if enrolled_at is present' do
      referral = build(:referral, enrolled_at: Time.current)
      expect(referral.status).to eq('enrolled')
    end

    it 'returns scheduled if scheduled_at is present' do
      referral = build(:referral, scheduled_at: Time.current)
      expect(referral.status).to eq('scheduled')
    end

    it 'returns referred if referred_at is present' do
      referral = build(:referral, referred_at: Time.current)
      expect(referral.status).to eq('referred')
    end

    it 'returns pending if no status timestamps are present' do
      referral = build(:referral)
      expect(referral.status).to eq('pending')
    end
  end

  describe 'status transition methods' do
    let(:referral) { create(:referral) }

    it 'marks as referred' do
      referral.mark_referred!
      expect(referral.referred_at).to be_present
      expect(referral.referred?).to be true
    end

    it 'marks as scheduled' do
      referral.mark_scheduled!
      expect(referral.scheduled_at).to be_present
      expect(referral.scheduled?).to be true
    end

    it 'marks as enrolled' do
      referral.mark_enrolled!
      expect(referral.enrolled_at).to be_present
      expect(referral.enrolled?).to be true
    end
  end

  describe 'scopes' do
    let!(:org1) { create(:organization, :district) }
    let!(:org2) { create(:organization, :district) }
    let!(:parent) { create(:parent) }
    
    let!(:referral1) { create(:referral, organization: org1, submitter: parent, referred_at: Time.current) }
    let!(:referral2) { create(:referral, organization: org2, submitter: parent) }
    let!(:referral3) { create(:referral, organization: org1, submitter: parent, scheduled_at: Time.current) }

    it 'filters by organization' do
      expect(Referral.by_organization(org1.id)).to include(referral1, referral3)
      expect(Referral.by_organization(org1.id)).not_to include(referral2)
    end

    it 'filters by submitter' do
      expect(Referral.by_submitter(parent.id)).to include(referral1, referral2, referral3)
    end

    it 'filters referred referrals' do
      expect(Referral.referred).to include(referral1)
      expect(Referral.referred).not_to include(referral2, referral3)
    end

    it 'filters scheduled referrals' do
      expect(Referral.scheduled).to include(referral3)
      expect(Referral.scheduled).not_to include(referral1, referral2)
    end
  end
end

