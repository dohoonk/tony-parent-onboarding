require 'rails_helper'

RSpec.describe Therapist, type: :model do
  describe 'associations' do
    it { should belong_to(:supervisor).optional }
    it { should belong_to(:associate_supervisor).optional }
    it { should have_many(:supervisees).dependent(:nullify) }
    it { should have_many(:associate_supervisees).dependent(:nullify) }
  end

  describe 'validations' do
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
    it { should allow_value('1234567890').for(:npi_number) }
    it { should_not allow_value('12345').for(:npi_number) }
    it { should allow_value('W2 Hourly').for(:employment_type) }
    it { should allow_value('1099 Contractor').for(:employment_type) }
    it { should_not allow_value('Invalid Type').for(:employment_type) }
  end

  describe 'scopes' do
    let!(:active_therapist) { create(:therapist, active: true) }
    let!(:inactive_therapist) { create(:therapist, active: false) }

    it 'returns only active therapists' do
      expect(Therapist.active).to include(active_therapist)
      expect(Therapist.active).not_to include(inactive_therapist)
    end
  end

  describe '#full_name' do
    it 'returns full name from first, middle, and last name' do
      therapist = build(:therapist, first_name: 'John', middle_name: 'Michael', last_name: 'Doe')
      expect(therapist.full_name).to eq('John Michael Doe')
    end

    it 'returns preferred name if names are blank' do
      therapist = build(:therapist, first_name: nil, last_name: nil, preferred_name: 'Johnny')
      expect(therapist.full_name).to eq('Johnny')
    end
  end

  describe '#display_name' do
    it 'returns preferred name if present' do
      therapist = build(:therapist, preferred_name: 'Johnny', first_name: 'John', last_name: 'Doe')
      expect(therapist.display_name).to eq('Johnny')
    end

    it 'falls back to full name if preferred name is blank' do
      therapist = build(:therapist, preferred_name: nil, first_name: 'John', last_name: 'Doe')
      expect(therapist.display_name).to eq('John Doe')
    end
  end

  describe '#capacity_utilization_percentage' do
    it 'calculates utilization correctly' do
      therapist = build(:therapist, capacity_total: 20, capacity_filled: 10)
      expect(therapist.capacity_utilization_percentage).to eq(50.0)
    end

    it 'returns 0 when capacity_total is zero' do
      therapist = build(:therapist, capacity_total: 0, capacity_filled: 0)
      expect(therapist.capacity_utilization_percentage).to eq(0)
    end
  end

  describe '#has_capacity?' do
    it 'returns true when capacity_available > 0' do
      therapist = build(:therapist, capacity_available: 5)
      expect(therapist.has_capacity?).to be true
    end

    it 'returns false when capacity_available is 0' do
      therapist = build(:therapist, capacity_available: 0)
      expect(therapist.has_capacity?).to be false
    end
  end

  describe '#licensed_in?' do
    it 'returns true when therapist is licensed in the state' do
      therapist = build(:therapist, licensed_states: ['CA', 'NY'])
      expect(therapist.licensed_in?('CA')).to be true
    end

    it 'returns false when therapist is not licensed in the state' do
      therapist = build(:therapist, licensed_states: ['CA', 'NY'])
      expect(therapist.licensed_in?('TX')).to be false
    end
  end

  describe '#speaks_language?' do
    it 'returns true when therapist speaks the language' do
      therapist = build(:therapist, care_languages: ['en', 'es'])
      expect(therapist.speaks_language?('en')).to be true
    end

    it 'returns false when therapist does not speak the language' do
      therapist = build(:therapist, care_languages: ['en'])
      expect(therapist.speaks_language?('es')).to be false
    end
  end

  describe 'callbacks' do
    describe '#normalize_email' do
      it 'downcases and strips email before validation' do
        therapist = build(:therapist, email: '  TEST@EXAMPLE.COM  ')
        therapist.valid? # Trigger before_validation callback
        expect(therapist.email).to eq('test@example.com')
      end
    end

    describe '#calculate_capacity_available' do
      it 'calculates capacity_available on save' do
        therapist = build(:therapist, capacity_total: 20, capacity_filled: 10)
        therapist.save
        expect(therapist.capacity_available).to eq(10)
      end
    end
  end
end

