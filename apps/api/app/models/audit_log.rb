class AuditLog < ApplicationRecord
  # Associations (polymorphic actor)
  # belongs_to :actor, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true, inclusion: { in: %w[read write update delete] }
  validates :entity_type, presence: true
  validates :entity_id, presence: true

  # Scopes
  scope :for_entity, ->(entity) { where(entity_type: entity.class.name, entity_id: entity.id) }
  scope :by_actor, ->(actor_id, actor_type) { where(actor_id: actor_id, actor_type: actor_type) }
  scope :recent, ->(limit = 100) { order(created_at: :desc).limit(limit) }

  # Class methods
  def self.log_access(actor:, action:, entity:, before: nil, after: nil, request: nil)
    create!(
      actor_id: actor&.id,
      actor_type: actor&.class&.name,
      action: action,
      entity_type: entity.class.name,
      entity_id: entity.id,
      before_json: before,
      after_json: after,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent
    )
  end

  # Instance methods
  def readonly?
    # Audit logs should never be modified or deleted once saved
    # But allow creation of new records
    persisted?
  end

  def before_destroy
    raise ActiveRecord::ReadOnlyRecord, "Audit logs cannot be deleted"
  end
end

