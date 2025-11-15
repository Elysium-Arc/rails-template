# frozen_string_literal: true

# Authorization concern for controllers
# Provides RBAC helper methods and integrates with Pundit
module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_has_role?, :current_user_has_permission?,
                  :current_user_has_any_role?, :current_user_has_any_permission?
  end

  # Check if current user has a specific role
  def current_user_has_role?(role_name, resource = nil)
    return false unless current_user

    current_user.has_role?(role_name, resource)
  end

  # Check if current user has any of the given roles
  def current_user_has_any_role?(*role_names)
    return false unless current_user

    current_user.has_any_role?(*role_names)
  end

  # Check if current user has a specific permission
  def current_user_has_permission?(permission_name, resource = nil)
    return false unless current_user

    current_user.has_permission?(permission_name, resource)
  end

  # Check if current user has any of the given permissions
  def current_user_has_any_permission?(*permission_names)
    return false unless current_user

    current_user.has_any_permission?(*permission_names)
  end

  # Authorize based on role
  def authorize_role!(*role_names)
    unless current_user_has_any_role?(*role_names)
      raise Pundit::NotAuthorizedError, "You must have one of these roles: #{role_names.join(', ')}"
    end
  end

  # Authorize based on permission
  def authorize_permission!(permission_name, resource = nil)
    unless current_user_has_permission?(permission_name, resource)
      raise Pundit::NotAuthorizedError, "You don't have permission: #{permission_name}"
    end
  end

  # Check if current user is admin
  def current_user_admin?
    return false unless current_user

    current_user.admin?
  end

  # Check if current user is super admin
  def current_user_super_admin?
    return false unless current_user

    current_user.super_admin?
  end
end
