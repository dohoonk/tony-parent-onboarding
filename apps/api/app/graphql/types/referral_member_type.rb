module Types
  class ReferralMemberType < Types::BaseObject
    description "A member (student or parent) associated with a referral"

    field :id, ID, null: false
    field :referral_id, ID, null: false
    field :user_id, ID, null: false
    field :user_type, String, null: false
    field :role, Integer, null: false
    field :data, GraphQL::Types::JSON, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Associations
    field :referral, Types::ReferralType, null: false
    field :user, Types::BaseObject, null: false # Polymorphic: Parent or Student
    field :user_as_parent, Types::ParentType, null: true
    field :user_as_student, Types::StudentType, null: true

    # Computed fields
    field :student, Boolean, null: false
    field :parent, Boolean, null: false

    # Computed field resolvers
    def student
      object.student?
    end

    def parent
      object.parent?
    end

    def user
      # Return the polymorphic user (Parent or Student)
      object.user
    end

    def user_as_parent
      object.user if object.user_type == 'Parent'
    end

    def user_as_student
      object.user if object.user_type == 'Student'
    end
  end
end

