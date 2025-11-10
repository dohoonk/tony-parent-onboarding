module Types
  class BaseObject < GraphQL::Schema::Object
    edge_type_class(Types::BaseEdge)
    connection_type_class(Types::BaseConnection)
    field_class Types::BaseField
    
    # Add a dummy field to satisfy GraphQL's requirement that object types have fields
    # This is a base class, so this field will be inherited by all child types
    # Child types can override this field if needed
    field :_typename, String, null: false, description: "GraphQL type name" do
      def resolve
        object.class.name
      end
    end
  end
end

