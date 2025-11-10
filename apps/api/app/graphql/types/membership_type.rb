module Types
  class MembershipType < Types::BaseObject
    description "A membership linking a user (parent or student) to an organization"

    field :id, ID, null: false
    field :user_id, ID, null: false
    field :user_type, String, null: false
    field :organization_id, ID, null: false
    field :census_person_id, String, null: true
    field :profile_data, GraphQL::Types::JSON, null: true
    field :migration_details, GraphQL::Types::JSON, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :user, Types::BaseObject, null: false # Polymorphic: Parent or Student
    field :organization, Types::OrganizationType, null: false
    field :user_as_parent, Types::ParentType, null: true
    field :user_as_student, Types::StudentType, null: true

    # Computed fields
    field :parent, Boolean, null: false
    field :student, Boolean, null: false

    # Computed field resolvers
    def parent
      object.parent?
    end

    def student
      object.student?
    end

    def user_as_parent
      object.user if object.user_type == 'Parent'
    end

    def user_as_student
      object.user if object.user_type == 'Student'
    end
  end
end

