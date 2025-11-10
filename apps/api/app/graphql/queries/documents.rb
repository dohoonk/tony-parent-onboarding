module Queries
  class Documents < BaseQuery
    type [Types::DocumentType], null: false
    description "List documents (consent forms, policies, etc.)"

    argument :label, String, required: false, description: "Filter by document label (e.g., 'privacy_policy', 'informed_consent')"
    argument :version, Integer, required: false, description: "Filter by version number"
    argument :latest_only, Boolean, required: false, default_value: false, description: "Return only latest version of each document"

    def resolve(label: nil, version: nil, latest_only: false)
      documents = Document.all

      # Apply filters
      documents = documents.by_label(label) if label.present?
      documents = documents.by_version(version) if version.present?

      # If latest_only, get only the latest version of each label
      if latest_only
        documents = documents.select('DISTINCT ON (label) *')
                            .order('label, version DESC')
      end

      documents.order(label: :asc, version: :desc)
    end
  end

  class Document < BaseQuery
    type Types::DocumentType, null: true
    description "Get a specific document by label and version"

    argument :label, String, required: true, description: "Document label (e.g., 'privacy_policy', 'informed_consent')"
    argument :version, Integer, required: false, description: "Version number (defaults to latest if not specified)"

    def resolve(label:, version: nil)
      documents = Document.by_label(label)
      
      if version.present?
        documents.find_by(version: version)
      else
        documents.latest.first
      end
    end
  end
end

