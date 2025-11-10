require 'rails_helper'

RSpec.describe Mutations::AiIntakeMessage, type: :graphql do
  let(:parent) { create(:parent) }
  let(:student) { create(:student, parent: parent) }
  let(:session) { create(:onboarding_session, parent: parent, student: student) }
  
  let(:mutation) do
    <<~GQL
      mutation AiIntakeMessage($input: AiIntakeMessageInput!) {
        aiIntakeMessage(input: $input) {
          message {
            id
            role
            content
          }
          assistantResponse {
            id
            role
            content
          }
          errors
        }
      }
    GQL
  end

  describe 'authenticated user' do
    let(:context) { authenticated_context(parent) }

    it 'creates user message and assistant response' do
      variables = { 
        input: { 
          sessionId: session.id.to_s,
          message: "My child has been feeling anxious"
        } 
      }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      expect(graphql_has_errors?(result)).to be false
      
      data = graphql_data(result, ['aiIntakeMessage'])
      expect(data['message']['role']).to eq('user')
      expect(data['message']['content']).to eq("My child has been feeling anxious")
      expect(data['assistantResponse']['role']).to eq('assistant')
      expect(data['assistantResponse']).not_to be_nil
    end

    it 'creates audit log entry' do
      variables = { 
        input: { 
          sessionId: session.id.to_s,
          message: "Test message"
        } 
      }
      
      expect {
        execute_graphql(mutation, variables: variables, context: context)
      }.to change(AuditLog, :count).by(1)
    end

    it 'returns error for non-existent session' do
      variables = { 
        input: { 
          sessionId: '99999',
          message: "Test"
        } 
      }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      data = graphql_data(result, ['aiIntakeMessage'])
      expect(data['errors']).to include('Session not found')
    end
  end

  describe 'unauthenticated user' do
    let(:context) { {} }

    it 'returns authentication error' do
      variables = { 
        input: { 
          sessionId: session.id.to_s,
          message: "Test"
        } 
      }
      
      result = execute_graphql(mutation, variables: variables, context: context)
      
      expect(graphql_has_errors?(result)).to be true
      expect(graphql_error_codes(result)).to include('AUTHENTICATION_REQUIRED')
    end
  end
end

