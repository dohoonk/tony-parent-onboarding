module Types
  class OrganizationType < Types::BaseObject
    description "An organization (district or school)"

    field :id, ID, null: false
    field :parent_organization_id, ID, null: true
    field :kind, Types::OrganizationKindEnum, null: false
    field :slug, String, null: false
    field :name, String, null: false
    field :internal_name, String, null: true
    field :tzdb, String, null: true
    field :market_id, ID, null: true
    field :config, GraphQL::Types::JSON, null: true
    field :enabled_at, GraphQL::Types::ISO8601DateTime, null: true
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Hierarchical relationships
    field :parent_organization, Types::OrganizationType, null: true
    field :child_organizations, [Types::OrganizationType], null: false

    # Computed fields
    field :district, Boolean, null: false
    field :school, Boolean, null: false
    field :enabled, Boolean, null: false
    field :full_path, String, null: false
    field :root_district, Types::OrganizationType, null: true
    field :all_schools, [Types::OrganizationType], null: false

    # Computed field resolvers
    def district
      object.district?
    end

    def school
      object.school?
    end

    def enabled
      object.enabled?
    end

    def full_path
      object.full_path
    end

    def root_district
      object.root_district
    end

    def all_schools
      object.all_schools
    end
  end
end

