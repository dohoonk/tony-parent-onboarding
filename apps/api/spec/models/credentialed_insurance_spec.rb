require 'rails_helper'

RSpec.describe CredentialedInsurance, type: :model do
  describe 'associations' do
    it { should belong_to(:parent_credentialed_insurance).optional }
    it { should have_many(:child_credentialed_insurances).dependent(:nullify) }
    it { should have_many(:clinician_credentialed_insurances).dependent(:destroy) }
    it { should have_many(:therapists) }
  end

  describe 'validations' do
    subject { build(:credentialed_insurance) }
    
    it { should validate_presence_of(:name) }
    it { should validate_inclusion_of(:network_status).in_array([0, 1]) }
    
    it 'sets default country to US' do
      insurance = build(:credentialed_insurance, country: nil)
      insurance.valid?
      expect(insurance.country).to eq('US')
    end
  end

  describe 'scopes' do
    let!(:in_network) { create(:credentialed_insurance, :in_network) }
    let!(:out_of_network) { create(:credentialed_insurance, :out_of_network) }

    it 'returns only in-network insurances' do
      expect(CredentialedInsurance.in_network).to include(in_network)
      expect(CredentialedInsurance.in_network).not_to include(out_of_network)
    end

    it 'returns only out-of-network insurances' do
      expect(CredentialedInsurance.out_of_network).to include(out_of_network)
      expect(CredentialedInsurance.out_of_network).not_to include(in_network)
    end
  end

  describe '#in_network?' do
    it 'returns true for in-network insurances' do
      insurance = build(:credentialed_insurance, :in_network)
      expect(insurance.in_network?).to be true
    end

    it 'returns false for out-of-network insurances' do
      insurance = build(:credentialed_insurance, :out_of_network)
      expect(insurance.in_network?).to be false
    end
  end

  describe '#display_name' do
    it 'returns name and state' do
      insurance = build(:credentialed_insurance, name: 'Aetna', state: 'CA')
      expect(insurance.display_name).to eq('Aetna - CA')
    end

    it 'returns just name if state is nil' do
      insurance = build(:credentialed_insurance, name: 'Aetna', state: nil)
      expect(insurance.display_name).to eq('Aetna')
    end
  end

  describe '#root_insurance' do
    it 'returns itself for root insurances' do
      insurance = create(:credentialed_insurance)
      expect(insurance.root_insurance).to eq(insurance)
    end

    it 'returns parent root for child insurances' do
      parent = create(:credentialed_insurance)
      child = create(:credentialed_insurance, parent_credentialed_insurance: parent)
      expect(child.root_insurance).to eq(parent)
    end
  end
end

