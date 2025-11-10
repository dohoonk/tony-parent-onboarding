module Types
  class DocumentType < Types::BaseObject
    description "A document (consent form, policy, etc.) with multi-language support"

    field :id, ID, null: false
    field :version, Integer, null: false
    field :label, String, null: false
    field :checkboxes, String, null: true
    field :version_date, GraphQL::Types::ISO8601Date, null: true
    field :urls, GraphQL::Types::JSON, null: false
    field :names, GraphQL::Types::JSON, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Computed fields for language-specific access
    field :url_for_language, String, null: true do
      argument :language, String, required: false, default_value: 'eng', description: "Language code (e.g., 'eng', 'spa')"
    end
    field :name_for_language, String, null: true do
      argument :language, String, required: false, default_value: 'eng', description: "Language code (e.g., 'eng', 'spa')"
    end
    field :available_languages, [String], null: false
    field :latest_version, Boolean, null: false

    def url_for_language(language: 'eng')
      object.url_for_language(language)
    end

    def name_for_language(language: 'eng')
      object.name_for_language(language)
    end

    def available_languages
      object.available_languages
    end

    def latest_version
      object.latest_version?
    end
  end
end

