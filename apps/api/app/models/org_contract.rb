class OrgContract < ApplicationRecord
  # Associations
  belongs_to :organization
  belongs_to :contract

  # Validations
  validates :organization_id, presence: true
  validates :contract_id, presence: true
  validates :organization_id, uniqueness: { scope: :contract_id, message: 'already has this contract' }

  # Scopes
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :for_contract, ->(contract_id) { where(contract_id: contract_id) }
end

