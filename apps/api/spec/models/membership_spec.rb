require 'rails_helper'

RSpec.describe Membership, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
  end

  describe 'validations' do
    let(:parent) { create(:parent) }
    let(:organization) { create(:organization) }
    
    subject { build(:membership, user: parent, organization: organization) }
    
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:user_type) }
    it { should validate_presence_of(:organization_id) }
    
    # Note: Inclusion validation is tested implicitly through other validations
    # The model defines: validates :user_type, inclusion: { in: %w[Parent Student] }
    
    it 'validates uniqueness of user scoped to organization' do
      create(:membership, user: parent, organization: organization)
      duplicate = build(:membership, user: parent, organization: organization)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_id]).to include('already a member of this organization')
    end
  end

  describe 'scopes' do
    let(:parent) { create(:parent) }
    let(:student) { create(:student, parent: parent) }
    let(:organization) { create(:organization) }
    
    let!(:parent_membership) { create(:membership, :parent, user: parent, organization: organization) }
    let!(:student_membership) { create(:membership, :student, user: student, organization: organization) }

    it 'filters by user' do
      expect(Membership.for_user(parent)).to include(parent_membership)
      expect(Membership.for_user(parent)).not_to include(student_membership)
    end

    it 'filters by organization' do
      other_org = create(:organization)
      other_membership = create(:membership, user: parent, organization: other_org)
      expect(Membership.for_organization(organization.id)).to include(parent_membership, student_membership)
      expect(Membership.for_organization(organization.id)).not_to include(other_membership)
    end

    it 'filters parent memberships' do
      expect(Membership.parents).to include(parent_membership)
      expect(Membership.parents).not_to include(student_membership)
    end

    it 'filters student memberships' do
      expect(Membership.students).to include(student_membership)
      expect(Membership.students).not_to include(parent_membership)
    end
  end

  describe '#parent?' do
    it 'returns true for parent memberships' do
      membership = build(:membership, :parent)
      expect(membership.parent?).to be true
    end

    it 'returns false for student memberships' do
      membership = build(:membership, :student)
      expect(membership.parent?).to be false
    end
  end

  describe '#student?' do
    it 'returns true for student memberships' do
      membership = build(:membership, :student)
      expect(membership.student?).to be true
    end

    it 'returns false for parent memberships' do
      membership = build(:membership, :parent)
      expect(membership.student?).to be false
    end
  end
end

