require 'rails_helper'

RSpec.describe Contract, type: :model do
  describe 'associations' do
    it { should have_many(:org_contracts).dependent(:destroy) }
    it { should have_many(:organizations).through(:org_contracts) }
  end

  describe 'validations' do
    subject { build(:contract) }
    
    it { should validate_presence_of(:effective_date) }
  end

  describe 'scopes' do
    let!(:active_contract) { create(:contract, :active) }
    let!(:expired_contract) { create(:contract, :expired) }
    let!(:upcoming_contract) { create(:contract, :upcoming) }

    it 'returns only active contracts' do
      expect(Contract.active).to include(active_contract)
      expect(Contract.active).not_to include(expired_contract, upcoming_contract)
    end

    it 'returns only expired contracts' do
      expect(Contract.expired).to include(expired_contract)
      expect(Contract.expired).not_to include(active_contract, upcoming_contract)
    end

    it 'returns only upcoming contracts' do
      expect(Contract.upcoming).to include(upcoming_contract)
      expect(Contract.upcoming).not_to include(active_contract, expired_contract)
    end
  end

  describe '#active?' do
    it 'returns true for active contracts' do
      contract = build(:contract, :active)
      expect(contract.active?).to be true
    end

    it 'returns false for expired contracts' do
      contract = build(:contract, :expired)
      expect(contract.active?).to be false
    end

    it 'returns true for contracts without end_date' do
      contract = build(:contract, :no_end_date, effective_date: 1.month.ago.to_date)
      expect(contract.active?).to be true
    end
  end

  describe '#has_service?' do
    it 'returns true when contract has the service' do
      contract = build(:contract, services: ['family_therapy', 'individual_therapy'])
      expect(contract.has_service?('family_therapy')).to be true
    end

    it 'returns false when contract does not have the service' do
      contract = build(:contract, services: ['family_therapy'])
      expect(contract.has_service?('individual_therapy')).to be false
    end
  end

  describe '#term_by_kind' do
    it 'returns the term for the specified kind' do
      contract = build(:contract, terms: [
        { 'kind' => 'sponsored', 'services' => ['family_therapy'] },
        { 'kind' => 'onsite', 'services' => ['onsite_care'] }
      ])
      expect(contract.term_by_kind('sponsored')['services']).to eq(['family_therapy'])
    end

    it 'returns nil when kind not found' do
      contract = build(:contract, terms: [{ 'kind' => 'sponsored' }])
      expect(contract.term_by_kind('nonexistent')).to be nil
    end
  end

  describe 'validation: end_date_after_effective_date' do
    it 'allows end_date after effective_date' do
      contract = build(:contract, effective_date: Date.current, end_date: 1.year.from_now.to_date)
      expect(contract).to be_valid
    end

    it 'rejects end_date before effective_date' do
      contract = build(:contract, effective_date: Date.current, end_date: 1.year.ago.to_date)
      expect(contract).not_to be_valid
      expect(contract.errors[:end_date]).to include('must be after effective date')
    end
  end
end

