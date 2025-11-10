module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField
    
    # Mark as abstract to exclude from schema
    # This is a base class, not a concrete queryable type
    abstract
  end
end

