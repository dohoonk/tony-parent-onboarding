module Authorizable
  extend ActiveSupport::Concern

  ROLES = {
    parent: 'parent',
    staff: 'staff',
    admin: 'admin',
    therapist: 'therapist'
  }.freeze

  PERMISSIONS = {
    parent: [:read_own, :write_own],
    staff: [:read_all, :write_own],
    therapist: [:read_assigned, :write_assigned, :schedule_appointments],
    admin: [:read_all, :write_all, :manage_users, :manage_roles]
  }.freeze

  included do
    validates :role, inclusion: { in: ROLES.values }, allow_nil: true
  end

  def has_role?(role_name)
    self.role == ROLES[role_name.to_sym]
  end

  def parent?
    has_role?(:parent)
  end

  def staff?
    has_role?(:staff)
  end

  def admin?
    has_role?(:admin)
  end

  def therapist?
    has_role?(:therapist)
  end

  def can?(permission)
    return false unless role.present?
    
    role_sym = ROLES.key(role)
    return false unless role_sym

    PERMISSIONS[role_sym]&.include?(permission) || false
  end

  def permissions
    return [] unless role.present?
    
    role_sym = ROLES.key(role)
    return [] unless role_sym

    PERMISSIONS[role_sym] || []
  end

  # Check if user can access a specific resource
  def can_access?(resource)
    return false unless resource

    case self.role
    when ROLES[:admin]
      true # Admins can access everything
    when ROLES[:parent]
      # Parents can only access their own data and their children's data
      can_access_as_parent?(resource)
    when ROLES[:therapist]
      # Therapists can access assigned students/sessions
      can_access_as_therapist?(resource)
    when ROLES[:staff]
      # Staff can read all, write own
      can_access_as_staff?(resource)
    else
      false
    end
  end

  private

  def can_access_as_parent?(resource)
    case resource
    when Parent
      resource.id == self.id
    when Student
      resource.parent_id == self.id
    when OnboardingSession
      resource.parent_id == self.id
    else
      # For associated resources, check through onboarding_session
      if resource.respond_to?(:onboarding_session)
        resource.onboarding_session&.parent_id == self.id
      elsif resource.respond_to?(:parent_id)
        resource.parent_id == self.id
      else
        false
      end
    end
  end

  def can_access_as_therapist?(resource)
    # TODO: Implement therapist assignment logic
    # For now, therapists can access resources they're assigned to via appointments
    case resource
    when Student
      resource.appointments.exists?(therapist_id: self.id)
    when OnboardingSession
      resource.student.appointments.exists?(therapist_id: self.id)
    when Appointment
      resource.therapist_id == self.id
    else
      false
    end
  end

  def can_access_as_staff?(resource)
    # Staff can read all resources but only write their own
    true # For MVP, staff has broad read access
  end
end

