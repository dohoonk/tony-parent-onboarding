require 'rails_helper'

RSpec.describe Queries::OnboardingSession, type: :graphql do
  let(:parent) { create(:parent) }
  let(:student) { create(:student, parent: parent) }
  let(:session) { create(:onboarding_session, parent: parent, student: student) }
  
  let(:query) do
    <<~GQL
      query OnboardingSession($id: ID!) {
        onboardingSession(id: $id) {
          id
          status
          currentStep
          parent {
            id
            email
          }
          student {
            id
            firstName
          }
        }
      }
    GQL
  end

  describe 'authenticated user' do
    let(:context) { authenticated_context(parent) }

    it 'returns onboarding session' do
      variables = { id: session.id.to_s }
      
      result = execute_graphql(query, variables: variables, context: context)
      
      expect(graphql_has_errors?(result)).to be false
      
      data = graphql_data(result, ['onboardingSession'])
      expect(data['id']).to eq(session.id.to_s)
      expect(data['status']).to eq(session.status)
      expect(data['parent']['id']).to eq(parent.id.to_s)
      expect(data['student']['id']).to eq(student.id.to_s)
    end

    it 'creates audit log entry' do
      variables = { id: session.id.to_s }
      
      expect {
        execute_graphql(query, variables: variables, context: context)
      }.to change(AuditLog, :count).by(1)
      
      audit = AuditLog.last
      expect(audit.action).to eq('read')
    end

    it 'returns nil for non-existent session' do
      variables = { id: '99999' }
      
      result = execute_graphql(query, variables: variables, context: context)
      
      data = graphql_data(result, ['onboardingSession'])
      expect(data).to be_nil
    end

    it 'returns nil for another parent\'s session' do
      other_parent = create(:parent)
      other_session = create(:onboarding_session, parent: other_parent)
      
      variables = { id: other_session.id.to_s }
      
      result = execute_graphql(query, variables: variables, context: context)
      
      data = graphql_data(result, ['onboardingSession'])
      expect(data).to be_nil
    end
  end

  describe 'unauthenticated user' do
    let(:context) { {} }

    it 'returns nil' do
      variables = { id: session.id.to_s }
      
      result = execute_graphql(query, variables: variables, context: context)
      
      data = graphql_data(result, ['onboardingSession'])
      expect(data).to be_nil
    end
  end
end

