require 'rails_helper'

RSpec.describe ClinicianCredentialedInsurance, type: :model do
  describe 'associations' do
    it { should belong_to(:therapist) }
    it { should belong_to(:credentialed_insurance) }
  end

  describe 'validations' do
    subject { build(:clinician_credentialed_insurance) }
    
    it { should validate_presence_of(:care_provider_profile_id) }
    it { should validate_presence_of(:credentialed_insurance_id) }
    
    it 'validates uniqueness of therapist scoped to insurance' do
      therapist = create(:therapist)
      insurance = create(:credentialed_insurance)
      create(:clinician_credentialed_insurance, therapist: therapist, credentialed_insurance: insurance)
      
      duplicate = build(:clinician_credentialed_insurance, therapist: therapist, credentialed_insurance: insurance)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:care_provider_profile_id]).to include('already credentialed for this insurance')
    end
  end

  describe 'scopes' do
    let!(:therapist1) { create(:therapist) }
    let!(:therapist2) { create(:therapist) }
    let!(:insurance1) { create(:credentialed_insurance) }
    let!(:insurance2) { create(:credentialed_insurance) }
    let!(:cred1) { create(:clinician_credentialed_insurance, therapist: therapist1, credentialed_insurance: insurance1) }
    let!(:cred2) { create(:clinician_credentialed_insurance, therapist: therapist2, credentialed_insurance: insurance1) }

    it 'filters by therapist' do
      expect(ClinicianCredentialedInsurance.for_therapist(therapist1.id)).to include(cred1)
      expect(ClinicianCredentialedInsurance.for_therapist(therapist1.id)).not_to include(cred2)
    end

    it 'filters by insurance' do
      expect(ClinicianCredentialedInsurance.for_insurance(insurance1.id)).to include(cred1, cred2)
    end

    it 'filters in-network credentials' do
      in_network_insurance = create(:credentialed_insurance, :in_network)
      out_of_network_insurance = create(:credentialed_insurance, :out_of_network)
      in_network_cred = create(:clinician_credentialed_insurance, therapist: therapist1, credentialed_insurance: in_network_insurance)
      out_of_network_cred = create(:clinician_credentialed_insurance, therapist: therapist1, credentialed_insurance: out_of_network_insurance)
      
      expect(ClinicianCredentialedInsurance.in_network).to include(in_network_cred)
      expect(ClinicianCredentialedInsurance.in_network).not_to include(out_of_network_cred)
    end
  end
end

