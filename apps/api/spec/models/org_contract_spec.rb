require 'rails_helper'

RSpec.describe OrgContract, type: :model do
  describe 'associations' do
    it { should belong_to(:organization) }
    it { should belong_to(:contract) }
  end

  describe 'validations' do
    subject { build(:org_contract) }
    
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:contract_id) }
    
    it 'validates uniqueness of organization_id scoped to contract_id' do
      org = create(:organization, :district)
      contract = create(:contract)
      create(:org_contract, organization: org, contract: contract)
      
      duplicate = build(:org_contract, organization: org, contract: contract)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:organization_id]).to include('already has this contract')
    end
  end

  describe 'scopes' do
    let!(:org1) { create(:organization, :district) }
    let!(:org2) { create(:organization, :district) }
    let!(:contract1) { create(:contract) }
    let!(:contract2) { create(:contract) }
    let!(:org_contract1) { create(:org_contract, organization: org1, contract: contract1) }
    let!(:org_contract2) { create(:org_contract, organization: org2, contract: contract1) }

    it 'filters by organization' do
      expect(OrgContract.for_organization(org1.id)).to include(org_contract1)
      expect(OrgContract.for_organization(org1.id)).not_to include(org_contract2)
    end

    it 'filters by contract' do
      expect(OrgContract.for_contract(contract1.id)).to include(org_contract1, org_contract2)
    end
  end
end

