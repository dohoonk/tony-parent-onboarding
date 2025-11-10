require 'rails_helper'

RSpec.describe Parent, type: :model do
  describe 'associations' do
    it { should have_many(:students).dependent(:destroy) }
    it { should have_many(:onboarding_sessions).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:auth_provider) }
    it { should validate_inclusion_of(:auth_provider).in_array(%w[magic_link]) }
  end

  describe 'callbacks' do
    describe '#normalize_email' do
      it 'downcases and strips email before validation' do
        parent = Parent.create(
          email: '  Test@EXAMPLE.com  ',
          first_name: 'Jane',
          last_name: 'Doe'
        )

        expect(parent.email).to eq('test@example.com')
      end
    end
  end
end

