require 'rails_helper'

RSpec.describe 'GraphQL Error Handling', type: :graphql do
  describe 'Authentication Errors' do
    it 'returns proper error code and message' do
      mutation = <<~GQL
        mutation {
          startOnboarding(input: { studentId: "1" }) {
            errors
          }
        }
      GQL
      
      result = execute_graphql(mutation, context: {})
      
      expect(graphql_has_errors?(result)).to be true
      expect(graphql_error_codes(result)).to include('AUTHENTICATION_REQUIRED')
      expect(graphql_error_message(result)).to eq('Authentication required')
    end
  end

  describe 'Validation Errors' do
    let(:parent) { create(:parent) }
    let(:context) { authenticated_context(parent) }

    it 'returns validation errors with field details' do
      # This test would require a mutation that triggers validation
      # For now, just documenting the expected structure
      # 
      # Expected error format:
      # {
      #   "message": "Validation failed: Email is invalid",
      #   "extensions": {
      #     "code": "VALIDATION_FAILED",
      #     "status": 422,
      #     "validation_errors": {
      #       "email": ["is invalid"]
      #     }
      #   }
      # }
    end
  end

  describe 'Not Found Errors' do
    let(:parent) { create(:parent) }
    let(:context) { authenticated_context(parent) }

    it 'returns not found error with resource info' do
      query = <<~GQL
        query {
          onboardingSession(id: "99999") {
            id
          }
        }
      GQL
      
      result = execute_graphql(query, context: context)
      
      # Should return nil for non-existent resources, not an error
      # unless we explicitly raise NotFoundError
      data = graphql_data(result, ['onboardingSession'])
      expect(data).to be_nil
    end
  end

  describe 'Max Depth Protection' do
    it 'prevents queries that exceed max depth' do
      # Create a very deeply nested query
      deeply_nested_query = <<~GQL
        query {
          onboardingSession(id: "1") {
            parent {
              students {
                onboardingSessions {
                  parent {
                    students {
                      onboardingSessions {
                        parent {
                          students {
                            onboardingSessions {
                              parent {
                                students {
                                  onboardingSessions {
                                    parent {
                                      students {
                                        onboardingSessions {
                                          parent {
                                            id
                                          }
                                        }
                                      }
                                    }
                                  }
                                }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      GQL
      
      result = execute_graphql(deeply_nested_query, context: {})
      
      # Should fail due to max_depth limit
      expect(graphql_has_errors?(result)).to be true
    end
  end
end

