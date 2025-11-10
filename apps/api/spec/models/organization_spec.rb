require 'rails_helper'

RSpec.describe Organization, type: :model do
  describe 'associations' do
    it { should belong_to(:parent_organization).optional }
    it { should have_many(:child_organizations).dependent(:nullify) }
  end

  describe 'validations' do
    subject { build(:organization, :district) }
    
    it { should validate_presence_of(:slug) }
    it { should validate_uniqueness_of(:slug).case_insensitive }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:kind) }
    it { should validate_inclusion_of(:kind).in_array(%w[district school]) }
  end

  describe 'scopes' do
    let!(:district) { create(:organization, :district) }
    let!(:school) { create(:organization, :school, parent_organization: district) }

    it 'returns only districts' do
      expect(Organization.districts).to include(district)
      expect(Organization.districts).not_to include(school)
    end

    it 'returns only schools' do
      expect(Organization.schools).to include(school)
      expect(Organization.schools).not_to include(district)
    end
  end

  describe '#district?' do
    it 'returns true for districts' do
      district = build(:organization, :district)
      expect(district.district?).to be true
    end

    it 'returns false for schools' do
      school = build(:organization, :school)
      expect(school.district?).to be false
    end
  end

  describe '#school?' do
    it 'returns true for schools' do
      school = build(:organization, :school)
      expect(school.school?).to be true
    end

    it 'returns false for districts' do
      district = build(:organization, :district)
      expect(district.school?).to be false
    end
  end

  describe '#enabled?' do
    it 'returns true when enabled_at is present' do
      org = build(:organization, enabled_at: Time.current)
      expect(org.enabled?).to be true
    end

    it 'returns false when enabled_at is nil' do
      org = build(:organization, enabled_at: nil)
      expect(org.enabled?).to be false
    end
  end

  describe '#root_district' do
    it 'returns itself for root districts' do
      district = create(:organization, :district)
      expect(district.root_district).to eq(district)
    end

    it 'returns parent district for schools' do
      district = create(:organization, :district)
      school = create(:organization, :school, parent_organization: district)
      expect(school.root_district).to eq(district)
    end
  end

  describe '#all_schools' do
    it 'returns all schools for a district' do
      district = create(:organization, :district)
      school1 = create(:organization, :school, parent_organization: district)
      school2 = create(:organization, :school, parent_organization: district)
      
      expect(district.all_schools).to include(school1, school2)
    end

    it 'returns empty array for schools' do
      district = create(:organization, :district)
      school = create(:organization, :school, parent_organization: district)
      expect(school.all_schools).to be_empty
    end
  end

  describe '#full_path' do
    it 'returns name for root districts' do
      district = create(:organization, :district, name: 'Test District')
      expect(district.full_path).to eq('Test District')
    end

    it 'returns hierarchical path for schools' do
      district = create(:organization, :district, name: 'Test District')
      school = create(:organization, :school, name: 'Test School', parent_organization: district)
      expect(school.full_path).to eq('Test District > Test School')
    end
  end

  describe 'validation: school_must_have_parent' do
    it 'allows districts without parent' do
      district = build(:organization, :district, parent_organization_id: nil)
      expect(district).to be_valid
    end

    it 'allows schools with parent' do
      district = create(:organization, :district)
      school = build(:organization, :school, parent_organization: district)
      expect(school).to be_valid
    end

    it 'rejects schools without parent' do
      school = build(:organization, :school, parent_organization_id: nil)
      expect(school).not_to be_valid
      expect(school.errors[:parent_organization_id]).to include('must be present for schools')
    end
  end

  describe 'callbacks' do
    describe '#normalize_slug' do
      it 'downcases and parameterizes slug' do
        org = build(:organization, slug: '  TEST ORG NAME  ')
        org.valid?
        expect(org.slug).to eq('test-org-name')
      end
    end
  end
end

