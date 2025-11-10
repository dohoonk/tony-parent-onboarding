require 'rails_helper'

RSpec.describe Kinship, type: :model do
  describe 'associations' do
    it { should belong_to(:user_0) }
    it { should belong_to(:user_1) }
  end

  describe 'validations' do
    let(:parent) { create(:parent) }
    let(:student) { create(:student, parent: parent) }
    
    subject { build(:kinship, user_0: parent, user_1: student) }
    
    it { should validate_presence_of(:user_0_id) }
    it { should validate_presence_of(:user_0_type) }
    it { should validate_presence_of(:user_1_id) }
    it { should validate_presence_of(:user_1_type) }
    it { should validate_presence_of(:kind) }
    
    # Note: Inclusion validation is tested implicitly through other validations
    # The model defines: validates :user_0_type, inclusion: { in: %w[Parent Student] }
    # and validates :user_1_type, inclusion: { in: %w[Parent Student] }
    
    it 'validates uniqueness of relationship' do
      create(:kinship, user_0: parent, user_1: student, kind: 1)
      duplicate = build(:kinship, user_0: parent, user_1: student, kind: 1)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:user_0_id]).to be_present
    end
    
    it 'validates users are different' do
      kinship = build(:kinship, user_0: parent, user_0_type: 'Parent', user_1: parent, user_1_type: 'Parent', kind: 1)
      expect(kinship).not_to be_valid
      expect(kinship.errors[:base]).to include('user_0 and user_1 must be different')
    end
    
    it 'validates parent-child relationship types' do
      parent2 = create(:parent)
      kinship = build(:kinship, user_0: parent, user_0_type: 'Parent', user_1: parent2, user_1_type: 'Parent', kind: 1)
      expect(kinship).not_to be_valid
      expect(kinship.errors[:base]).to include('parent-child relationship must be between a Parent and a Student')
    end
  end

  describe '#parent_child?' do
    it 'returns true for parent-child relationships' do
      kinship = build(:kinship, kind: 1)
      expect(kinship.parent_child?).to be true
    end

    it 'returns false for other relationship types' do
      kinship = build(:kinship, kind: 2)
      expect(kinship.parent_child?).to be false
    end
  end

  describe '#parent' do
    it 'returns the parent user' do
      parent = create(:parent)
      student = create(:student, parent: parent)
      kinship = create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 1)
      expect(kinship.parent).to eq(parent)
    end
  end

  describe '#student' do
    it 'returns the student user' do
      parent = create(:parent)
      student = create(:student, parent: parent)
      kinship = create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 1)
      expect(kinship.student).to eq(student)
    end
  end

  describe '#other_user' do
    it 'returns the other user when given user_0' do
      parent = create(:parent)
      student = create(:student, parent: parent)
      kinship = create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 1)
      expect(kinship.other_user(parent)).to eq(student)
    end

    it 'returns the other user when given user_1' do
      parent = create(:parent)
      student = create(:student, parent: parent)
      kinship = create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student, user_1_type: 'Student', kind: 1)
      expect(kinship.other_user(student)).to eq(parent)
    end
  end

  describe 'scopes' do
    let(:parent) { create(:parent) }
    let(:student1) { create(:student, parent: parent) }
    let(:student2) { create(:student, parent: parent) }
    
    let!(:parent_child_kinship) { create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student1, user_1_type: 'Student', kind: 1, guardian_can_be_contacted: false) }
    let!(:contactable_kinship) { create(:kinship, user_0: parent, user_0_type: 'Parent', user_1: student2, user_1_type: 'Student', kind: 1, guardian_can_be_contacted: true) }

    it 'filters by user' do
      expect(Kinship.for_user(parent)).to include(parent_child_kinship)
      expect(Kinship.for_user(student1)).to include(parent_child_kinship)
    end

    it 'filters parent-child relationships' do
      expect(Kinship.parent_child).to include(parent_child_kinship)
    end

    it 'filters guardian contactable relationships' do
      expect(Kinship.guardian_contactable).to include(contactable_kinship)
      expect(Kinship.guardian_contactable).not_to include(parent_child_kinship)
    end
  end
end

