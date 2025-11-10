module Types
  class KinshipType < Types::BaseObject
    description "A relationship between two users (parent-child relationship)"

    field :id, ID, null: false
    field :user_0_id, ID, null: false
    field :user_0_type, String, null: false
    field :user_1_id, ID, null: false
    field :user_1_type, String, null: false
    field :kind, Integer, null: false
    field :user_0_label, String, null: true
    field :user_1_label, String, null: true
    field :guardian_can_be_contacted, Boolean, null: false
    field :migration_details, GraphQL::Types::JSON, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :user_0, Types::BaseObject, null: false # Polymorphic: Parent or Student
    field :user_1, Types::BaseObject, null: false # Polymorphic: Parent or Student
    field :user_0_as_parent, Types::ParentType, null: true
    field :user_0_as_student, Types::StudentType, null: true
    field :user_1_as_parent, Types::ParentType, null: true
    field :user_1_as_student, Types::StudentType, null: true

    # Computed fields
    field :parent_child, Boolean, null: false
    field :parent, Types::ParentType, null: true
    field :student, Types::StudentType, null: true

    # Computed field resolvers
    def parent_child
      object.parent_child?
    end

    def parent
      object.parent
    end

    def student
      object.student
    end

    def user_0_as_parent
      object.user_0 if object.user_0_type == 'Parent'
    end

    def user_0_as_student
      object.user_0 if object.user_0_type == 'Student'
    end

    def user_1_as_parent
      object.user_1 if object.user_1_type == 'Parent'
    end

    def user_1_as_student
      object.user_1 if object.user_1_type == 'Student'
    end
  end
end

