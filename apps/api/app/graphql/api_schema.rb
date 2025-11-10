class ApiSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # Max depth and complexity to prevent DoS
  max_depth 15
  max_complexity 500

  # Default max page size for connections
  default_max_page_size 100

  # Error handling
  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    raise Errors::NotFoundError.new(
      message: "#{field.owner.name.demodulize.gsub('Type', '')} not found",
      resource: field.owner.name.demodulize.gsub('Type', '').underscore
    )
  end

  rescue_from(ActiveRecord::RecordInvalid) do |err, obj, args, ctx, field|
    raise Errors::ValidationError.from_active_record(err.record)
  end

  rescue_from(Errors::AuthenticationError) do |err, obj, args, ctx, field|
    # Log authentication failure
    Rails.logger.warn("Authentication error: #{err.message}")
    raise err
  end

  rescue_from(Errors::AuthorizationError) do |err, obj, args, ctx, field|
    # Log authorization failure
    Rails.logger.warn("Authorization error: #{err.message} - User: #{ctx[:current_user]&.id}")
    raise err
  end

  rescue_from(StandardError) do |err, obj, args, ctx, field|
    # Log unexpected errors
    Rails.logger.error("GraphQL Error: #{err.class} - #{err.message}")
    Rails.logger.error(err.backtrace.join("\n"))
    
    # Return generic error in production
    if Rails.env.production?
      raise GraphQL::ExecutionError.new(
        "An unexpected error occurred",
        extensions: { code: 'INTERNAL_ERROR', status: 500 }
      )
    else
      raise err
    end
  end

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this method
    # to return the correct GraphQL object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    GlobalID.find(global_id)
  end
end

