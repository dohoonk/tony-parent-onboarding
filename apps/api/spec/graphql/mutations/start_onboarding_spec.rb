require 'rails_helper'

RSpec.describe Mutations::StartOnboarding, type: :graphql do
  let(:parent) { create(:parent) }
  let(:student) { create(:student, parent: parent) }
  
  let(:mutation) do
    <<~GQL
      mutation StartOnboarding($input: StartOnboardingInput!) {
        startOnboarding(input: $input) {
          session {
            id
            status
            currentStep
            student {
              id
              firstName
            }
            parent {
              id
              email
            }
          }
          errors
        }
      }
    GQL
  end

  describe 'authenticated user' do
    let(:context) { authenticated_context(parent) }

    it 'creates a new onboarding session' do
      variables = { input: { studentId: student.id.to_s } }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      expect(graphql_has_errors?(result)).to be false
      
      data = graphql_data(result, ['startOnboarding', 'session'])
      expect(data['status']).to eq('active')
      expect(data['currentStep']).to eq(1)
      expect(data['student']['id']).to eq(student.id.to_s)
      expect(data['parent']['id']).to eq(parent.id.to_s)
    end

    it 'returns existing active session if one exists' do
      existing_session = create(:onboarding_session, 
        parent: parent, 
        student: student, 
        status: 'active'
      )
      
      variables = { input: { studentId: student.id.to_s } }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      data = graphql_data(result, ['startOnboarding', 'session'])
      expect(data['id']).to eq(existing_session.id.to_s)
      
      # Should not create a new session
      expect(OnboardingSession.count).to eq(1)
    end

    it 'returns error for non-existent student' do
      variables = { input: { studentId: '99999' } }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      data = graphql_data(result, ['startOnboarding'])
      expect(data['errors']).to include('Student not found')
      expect(data['session']).to be_nil
    end

    it 'creates audit log entry' do
      variables = { input: { studentId: student.id.to_s } }
      
      expect {
        execute_graphql(mutation, variables: variables, context: context)
      }.to change(AuditLog, :count).by(1)
      
      audit = AuditLog.last
      expect(audit.action).to eq('write')
      expect(audit.actor_type).to eq('Parent')
      expect(audit.entity_type).to eq('OnboardingSession')
    end
  end

  describe 'unauthenticated user' do
    let(:context) { {} }

    it 'returns authentication error' do
      variables = { input: { studentId: student.id.to_s } }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      expect(graphql_has_errors?(result)).to be true
      expect(graphql_error_codes(result)).to include('AUTHENTICATION_REQUIRED')
    end
  end
end

