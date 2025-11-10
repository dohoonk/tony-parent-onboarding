require 'rails_helper'

RSpec.describe Student, type: :model do
  describe 'associations' do
    it { should belong_to(:parent) }
    it { should have_many(:onboarding_sessions).dependent(:destroy) }
    it { should have_many(:appointments).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:date_of_birth) }
    it { should validate_presence_of(:language) }

    describe 'date_of_birth validation' do
      let(:parent) { Parent.create!(email: 'test@example.com', first_name: 'John', last_name: 'Doe') }

      it 'rejects future dates' do
        student = Student.new(
          parent: parent,
          first_name: 'Jane',
          last_name: 'Doe',
          date_of_birth: 1.day.from_now
        )

        expect(student).not_to be_valid
        expect(student.errors[:date_of_birth]).to include("cannot be in the future")
      end

      it 'rejects dates too far in the past' do
        student = Student.new(
          parent: parent,
          first_name: 'Jane',
          last_name: 'Doe',
          date_of_birth: 101.years.ago
        )

        expect(student).not_to be_valid
        expect(student.errors[:date_of_birth]).to include("is too far in the past")
      end

      it 'accepts valid dates' do
        student = Student.new(
          parent: parent,
          first_name: 'Jane',
          last_name: 'Doe',
          date_of_birth: 10.years.ago
        )

        expect(student).to be_valid
      end
    end
  end

  describe '#age' do
    let(:parent) { Parent.create!(email: 'test@example.com', first_name: 'John', last_name: 'Doe') }
    
    it 'calculates age correctly' do
      student = Student.create!(
        parent: parent,
        first_name: 'Jane',
        last_name: 'Doe',
        date_of_birth: 10.years.ago
      )

      expect(student.age).to eq(10)
    end

    it 'returns nil when date_of_birth is not set' do
      student = Student.new(parent: parent, first_name: 'Jane', last_name: 'Doe')
      expect(student.age).to be_nil
    end
  end
end

