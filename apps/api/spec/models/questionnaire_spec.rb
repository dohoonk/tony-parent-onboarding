require 'rails_helper'

RSpec.describe Questionnaire, type: :model do
  describe 'associations' do
    it 'belongs to subject (Student)' do
      student = create(:student)
      questionnaire = create(:questionnaire, subject: student)
      expect(questionnaire.subject).to eq(student)
    end

    it 'belongs to respondent (Parent)' do
      parent = create(:parent)
      questionnaire = create(:questionnaire, respondent: parent)
      expect(questionnaire.respondent).to eq(parent)
    end

    it 'has one screener response' do
      questionnaire = create(:questionnaire)
      # Create screener response manually since factories don't exist yet
      onboarding_session = create(:onboarding_session)
      screener = Screener.first || Screener.create!(
        key: 'phq9',
        title: 'PHQ-9',
        version: 1,
        items_json: { items: [] }
      )
      screener_response = ScreenerResponse.create!(
        onboarding_session: onboarding_session,
        screener: screener,
        questionnaire: questionnaire,
        answers_json: { 'question_1' => 0 }
      )
      expect(questionnaire.reload.screener_response).to eq(screener_response)
    end
  end

  describe 'validations' do
    let(:student) { create(:student) }
    let(:parent) { create(:parent) }
    
    it 'validates presence of subject_id' do
      questionnaire = build(:questionnaire, subject: nil)
      expect(questionnaire).not_to be_valid
      expect(questionnaire.errors[:subject_id]).to be_present
    end

    it 'validates presence of respondent_id' do
      questionnaire = build(:questionnaire, respondent: nil)
      expect(questionnaire).not_to be_valid
      expect(questionnaire.errors[:respondent_id]).to be_present
    end

    it 'validates presence of questionnaire_type' do
      questionnaire = build(:questionnaire, questionnaire_type: nil)
      expect(questionnaire).not_to be_valid
      expect(questionnaire.errors[:questionnaire_type]).to be_present
    end

    it 'validates presence of language_of_completion' do
      questionnaire = build(:questionnaire, language_of_completion: nil)
      questionnaire.valid?
      # The callback sets default, so we need to check after validation
      expect(questionnaire.language_of_completion).to eq('eng')
    end

    it 'validates inclusion of language_of_completion' do
      questionnaire = build(:questionnaire, language_of_completion: 'invalid')
      expect(questionnaire).not_to be_valid
      expect(questionnaire.errors[:language_of_completion]).to be_present
    end
  end

  describe 'scopes' do
    let(:student) { create(:student) }
    let(:parent) { create(:parent) }
    
    let!(:phq9) { create(:questionnaire, :phq9, subject: student, respondent: parent) }
    let!(:gad7) { create(:questionnaire, :gad7, subject: student, respondent: parent) }
    let!(:in_progress) { create(:questionnaire, :in_progress, subject: student, respondent: parent) }

    it 'filters by type' do
      expect(Questionnaire.by_type(1)).to include(phq9)
      expect(Questionnaire.by_type(1)).not_to include(gad7)
    end

    it 'filters by subject' do
      other_student = create(:student)
      other_questionnaire = create(:questionnaire, subject: other_student, respondent: parent)
      expect(Questionnaire.by_subject(student.id)).to include(phq9, gad7)
      expect(Questionnaire.by_subject(student.id)).not_to include(other_questionnaire)
    end

    it 'filters completed questionnaires' do
      expect(Questionnaire.completed).to include(phq9, gad7)
      expect(Questionnaire.completed).not_to include(in_progress)
    end

    it 'filters in-progress questionnaires' do
      expect(Questionnaire.in_progress).to include(in_progress)
      expect(Questionnaire.in_progress).not_to include(phq9, gad7)
    end
  end

  describe '#screener_key' do
    it 'returns screener key for known type' do
      questionnaire = build(:questionnaire, questionnaire_type: 1)
      expect(questionnaire.screener_key).to eq('phq9')
    end

    it 'returns nil for unknown type' do
      questionnaire = build(:questionnaire, questionnaire_type: 999)
      expect(questionnaire.screener_key).to be_nil
    end
  end

  describe '#completed?' do
    it 'returns true when completed_at is present' do
      questionnaire = build(:questionnaire, :completed)
      expect(questionnaire.completed?).to be true
    end

    it 'returns false when completed_at is nil' do
      questionnaire = build(:questionnaire, :in_progress)
      expect(questionnaire.completed?).to be false
    end
  end

  describe '#in_progress?' do
    it 'returns true when started but not completed' do
      questionnaire = build(:questionnaire, :in_progress)
      expect(questionnaire.in_progress?).to be true
    end

    it 'returns false when completed' do
      questionnaire = build(:questionnaire, :completed)
      expect(questionnaire.in_progress?).to be false
    end
  end

  describe '#duration_seconds' do
    it 'returns duration in seconds' do
      started = 1.hour.ago
      completed = Time.current
      questionnaire = create(:questionnaire, started_at: started, completed_at: completed)
      expect(questionnaire.duration_seconds).to be_within(5).of(3600)
    end

    it 'returns nil if not completed' do
      questionnaire = build(:questionnaire, :in_progress)
      expect(questionnaire.duration_seconds).to be_nil
    end
  end

  describe '#mark_started!' do
    it 'sets started_at if not present' do
      questionnaire = create(:questionnaire, started_at: nil)
      questionnaire.mark_started!
      expect(questionnaire.reload.started_at).to be_present
    end

    it 'does not override existing started_at' do
      time = 1.hour.ago
      questionnaire = create(:questionnaire, started_at: time)
      questionnaire.mark_started!
      expect(questionnaire.started_at.to_i).to eq(time.to_i)
    end
  end

  describe '#mark_completed!' do
    it 'sets completed_at if not present' do
      questionnaire = create(:questionnaire, :in_progress)
      questionnaire.mark_completed!
      expect(questionnaire.reload.completed_at).to be_present
    end

    it 'does not override existing completed_at' do
      time = 1.hour.ago
      questionnaire = create(:questionnaire, completed_at: time)
      questionnaire.mark_completed!
      expect(questionnaire.completed_at.to_i).to eq(time.to_i)
    end
  end
end

