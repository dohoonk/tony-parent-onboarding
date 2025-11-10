module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField
    
    # Mark as having no fields - this is a base class, not a concrete type
    # Prevents GraphQL from requiring fields on this abstract base class
    has_no_fields
  end
end

