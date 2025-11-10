require 'rails_helper'

RSpec.describe Document, type: :model do
  describe 'validations' do
    subject { build(:document) }
    
    it { should validate_presence_of(:version) }
    it { should validate_presence_of(:label) }
    it { should validate_numericality_of(:version).is_greater_than(0).only_integer }
    it 'validates uniqueness of label scoped to version' do
      create(:document, label: 'test_doc', version: 1)
      duplicate = build(:document, label: 'test_doc', version: 1)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:label]).to be_present
    end
  end

  describe 'scopes' do
    let!(:privacy_v1) { create(:document, label: 'privacy_policy', version: 1) }
    let!(:privacy_v2) { create(:document, label: 'privacy_policy', version: 2) }
    let!(:consent) { create(:document, :informed_consent, version: 1) }

    it 'filters by label' do
      expect(Document.by_label('privacy_policy')).to include(privacy_v1, privacy_v2)
      expect(Document.by_label('privacy_policy')).not_to include(consent)
    end

    it 'filters by version' do
      expect(Document.by_version(1)).to include(privacy_v1, consent)
      expect(Document.by_version(1)).not_to include(privacy_v2)
    end

    it 'orders by latest version' do
      expect(Document.latest.first).to eq(privacy_v2)
    end
  end

  describe '#url_for_language' do
    let(:document) { create(:document, urls: { 'eng' => 'https://example.com/eng', 'spa' => 'https://example.com/spa' }) }

    it 'returns URL for specified language' do
      expect(document.url_for_language('spa')).to eq('https://example.com/spa')
    end

    it 'falls back to English if language not found' do
      expect(document.url_for_language('fr')).to eq('https://example.com/eng')
    end

    it 'falls back to first available URL if English not found' do
      doc = create(:document, urls: { 'spa' => 'https://example.com/spa' })
      expect(doc.url_for_language('fr')).to eq('https://example.com/spa')
    end
  end

  describe '#name_for_language' do
    let(:document) { create(:document, names: { 'eng' => 'Privacy Policy', 'spa' => 'Política de Privacidad' }) }

    it 'returns name for specified language' do
      expect(document.name_for_language('spa')).to eq('Política de Privacidad')
    end

    it 'falls back to English if language not found' do
      expect(document.name_for_language('fr')).to eq('Privacy Policy')
    end
  end

  describe '#available_languages' do
    it 'returns list of available language codes' do
      document = create(:document, urls: { 'eng' => 'url1', 'spa' => 'url2', 'fr' => 'url3' })
      expect(document.available_languages).to match_array(['eng', 'spa', 'fr'])
    end
  end

  describe '#latest_version?' do
    let!(:v1) { create(:document, label: 'test_doc', version: 1) }
    let!(:v2) { create(:document, label: 'test_doc', version: 2) }
    let!(:v3) { create(:document, label: 'test_doc', version: 3) }

    it 'returns true for latest version' do
      expect(v3.latest_version?).to be true
    end

    it 'returns false for older versions' do
      expect(v1.latest_version?).to be false
      expect(v2.latest_version?).to be false
    end
  end
end

