require 'rails_helper'

RSpec.describe ReferralMember, type: :model do
  describe 'associations' do
    it { should belong_to(:referral) }
    it { should belong_to(:user) }
  end

  describe 'validations' do
    let(:referral) { create(:referral) }
    let(:student) { create(:student) }
    
    subject { build(:referral_member, referral: referral, user: student, user_type: 'Student', role: 0) }
    
    it { should validate_presence_of(:referral_id) }
    it { should validate_presence_of(:user_id) }
    it { should validate_inclusion_of(:role).in_array([0, 1]) }
    
    it 'sets user_type from role via callback' do
      member = build(:referral_member, referral: referral, user: student, role: 0, user_type: nil)
      member.valid?
      expect(member.user_type).to eq('Student')
    end
    
    it 'validates uniqueness of user scoped to referral and user_type' do
      referral = create(:referral)
      student = create(:student)
      create(:referral_member, referral: referral, user: student, user_type: 'Student', role: 0)
      
      duplicate = build(:referral_member, referral: referral, user: student, user_type: 'Student', role: 0)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('already a member of this referral')
    end
  end

  describe '#student?' do
    it 'returns true for student members' do
      member = build(:referral_member, :student)
      expect(member.student?).to be true
    end

    it 'returns false for parent members' do
      member = build(:referral_member, :parent)
      expect(member.student?).to be false
    end
  end

  describe '#parent?' do
    it 'returns true for parent members' do
      member = build(:referral_member, :parent)
      expect(member.parent?).to be true
    end

    it 'returns false for student members' do
      member = build(:referral_member, :student)
      expect(member.parent?).to be false
    end
  end

  describe 'scopes' do
    let!(:referral) { create(:referral) }
    let!(:student) { create(:student) }
    let!(:parent) { create(:parent) }
    
    let!(:student_member) { create(:referral_member, :student, referral: referral, user: student) }
    let!(:parent_member) { create(:referral_member, :parent, referral: referral, user: parent) }

    it 'filters student members' do
      expect(ReferralMember.students).to include(student_member)
      expect(ReferralMember.students).not_to include(parent_member)
    end

    it 'filters parent members' do
      expect(ReferralMember.parents).to include(parent_member)
      expect(ReferralMember.parents).not_to include(student_member)
    end
  end
end

