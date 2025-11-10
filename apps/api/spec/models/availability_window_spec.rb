require 'rails_helper'

RSpec.describe AvailabilityWindow, type: :model do
  describe 'associations' do
    it { should belong_to(:owner) }
  end

  describe 'validations' do
    subject { build(:availability_window) }
    
    it { should validate_presence_of(:owner_type) }
    it { should validate_presence_of(:owner_id) }
    it { should validate_presence_of(:start_date) }
    it { should validate_inclusion_of(:owner_type).in_array(%w[Parent Therapist Student]) }
  end

  describe '#uses_json_format?' do
    it 'returns true when availability_json has days' do
      window = build(:availability_window, availability_json: { 'days' => [] })
      expect(window.uses_json_format?).to be true
    end

    it 'returns false when availability_json is empty' do
      window = build(:availability_window, availability_json: {})
      expect(window.uses_json_format?).to be false
    end
  end

  describe '#uses_rrule_format?' do
    it 'returns true when rrule is present' do
      window = build(:availability_window, rrule: 'FREQ=WEEKLY;BYDAY=MO')
      expect(window.uses_rrule_format?).to be true
    end

    it 'returns false when rrule is nil' do
      window = build(:availability_window, rrule: nil)
      expect(window.uses_rrule_format?).to be false
    end
  end

  describe '#available_on_day?' do
    it 'returns true when day is in availability_json' do
      window = build(:availability_window, availability_json: {
        'days' => [
          { 'day' => 'Monday', 'time_blocks' => [] }
        ]
      })
      expect(window.available_on_day?('Monday')).to be true
    end

    it 'returns false when day is not in availability_json' do
      window = build(:availability_window, availability_json: {
        'days' => [
          { 'day' => 'Monday', 'time_blocks' => [] }
        ]
      })
      expect(window.available_on_day?('Tuesday')).to be false
    end
  end

  describe '#time_blocks_for_day' do
    it 'returns time blocks for the specified day' do
      window = build(:availability_window, availability_json: {
        'days' => [
          { 'day' => 'Monday', 'time_blocks' => [
            { 'start' => '09:00:00', 'duration' => 60 }
          ]}
        ]
      })
      blocks = window.time_blocks_for_day('Monday')
      expect(blocks.length).to eq(1)
      expect(blocks.first['start']).to eq('09:00:00')
    end

    it 'returns empty array when day not found' do
      window = build(:availability_window, availability_json: {
        'days' => [
          { 'day' => 'Monday', 'time_blocks' => [] }
        ]
      })
      expect(window.time_blocks_for_day('Tuesday')).to eq([])
    end
  end

  describe '#available_at_time?' do
    it 'returns true when time falls within a time block' do
      window = build(:availability_window, availability_json: {
        'days' => [
          { 'day' => 'Monday', 'time_blocks' => [
            { 'start' => '09:00:00', 'duration' => 60 }
          ]}
        ]
      })
      expect(window.available_at_time?('Monday', '09:30:00')).to be true
    end

    it 'returns false when time is outside time blocks' do
      window = build(:availability_window, availability_json: {
        'days' => [
          { 'day' => 'Monday', 'time_blocks' => [
            { 'start' => '09:00:00', 'duration' => 60 }
          ]}
        ]
      })
      expect(window.available_at_time?('Monday', '10:30:00')).to be false
    end
  end

  describe 'validation: has_availability_data' do
    let(:therapist) { create(:therapist) }

    it 'allows window with rrule' do
      window = build(:availability_window, owner: therapist, rrule: 'FREQ=WEEKLY', availability_json: nil)
      expect(window).to be_valid
    end

    it 'allows window with availability_json' do
      window = build(:availability_window, owner: therapist, rrule: nil, availability_json: { 'days' => [] })
      expect(window).to be_valid
    end

    it 'rejects window without either format' do
      window = build(:availability_window, owner: therapist, rrule: nil, availability_json: nil)
      expect(window).not_to be_valid
      expect(window.errors[:base]).to include('must have either rrule or availability_json')
    end
  end

  describe 'callbacks' do
    describe '#normalize_availability_json' do
      it 'converts string JSON to hash' do
        json_string = '{"days": [{"day": "Monday", "time_blocks": []}]}'
        window = build(:availability_window, availability_json: json_string)
        window.valid?
        expect(window.availability_json).to be_a(Hash)
        expect(window.availability_json['days']).to be_an(Array)
      end

      it 'wraps array in hash with days key' do
        window = build(:availability_window, availability_json: [
          { 'day' => 'Monday', 'time_blocks' => [] }
        ])
        window.valid?
        expect(window.availability_json).to be_a(Hash)
        expect(window.availability_json['days']).to be_an(Array)
      end

      it 'capitalizes day names' do
        window = build(:availability_window, availability_json: {
          'days' => [
            { 'day' => 'monday', 'time_blocks' => [] }
          ]
        })
        window.valid?
        expect(window.availability_json['days'].first['day']).to eq('Monday')
      end
    end
  end
end

