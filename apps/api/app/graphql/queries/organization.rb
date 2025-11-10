module Queries
  class Organization < BaseQuery
    description "Find an organization by ID or slug"

    argument :id, ID, required: false, description: "Organization UUID"
    argument :slug, String, required: false, description: "Organization slug"

    type Types::OrganizationType, null: true

    def resolve(id: nil, slug: nil)
      if id.present?
        ::Organization.find_by(id: id)
      elsif slug.present?
        ::Organization.find_by(slug: slug)
      else
        nil
      end
    end
  end
end

