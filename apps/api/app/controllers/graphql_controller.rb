class GraphqlController < ApplicationController
  include Authentication

  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  # Skip authentication for specific operations (if needed)
  # skip_before_action :authenticate_request, only: [:execute], if: :public_operation?

  def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    
    context = {
      current_user: current_user,
      controller: self
    }
    
    result = ApiSchema.execute(
      query, 
      variables: variables, 
      context: context, 
      operation_name: operation_name
    )
    
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end

  # Uncomment to allow specific operations without authentication
  # def public_operation?
  #   introspection_query? || health_check_query?
  # end
  #
  # def introspection_query?
  #   params[:operationName] == 'IntrospectionQuery'
  # end
  #
  # def health_check_query?
  #   params[:query]&.include?('healthCheck')
  # end
end

