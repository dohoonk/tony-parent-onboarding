module GraphqlHelpers
  # Execute a GraphQL query/mutation
  def execute_graphql(query, variables: {}, context: {})
    ApiSchema.execute(
      query,
      variables: variables,
      context: context
    )
  end

  # Helper to generate JWT token for authentication
  def generate_auth_token(parent)
    JwtService.encode(parent)
  end

  # Helper to create authenticated context
  def authenticated_context(parent)
    {
      current_user: parent,
      controller: double('Controller')
    }
  end

  # Helper to extract data from GraphQL response
  def graphql_data(result, path = [])
    data = result['data']
    path.reduce(data) { |acc, key| acc&.dig(key) }
  end

  # Helper to extract errors from GraphQL response
  def graphql_errors(result)
    result['errors'] || []
  end

  # Helper to check if GraphQL response has errors
  def graphql_has_errors?(result)
    graphql_errors(result).any?
  end

  # Helper to extract first error message
  def graphql_error_message(result)
    graphql_errors(result).first&.dig('message')
  end

  # Helper to extract error codes
  def graphql_error_codes(result)
    graphql_errors(result).map { |err| err.dig('extensions', 'code') }.compact
  end
end

RSpec.configure do |config|
  config.include GraphqlHelpers, type: :graphql
end

