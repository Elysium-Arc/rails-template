# frozen_string_literal: true

class RbacService
  class RoleNotFoundError < StandardError; end
  class PermissionNotFoundError < StandardError; end

  def self.create_role(name, description = nil, resource_type = nil, resource_id = nil)
    Role.create!(
      name: name,
      description: description,
      resource_type: resource_type,
      resource_id: resource_id
    )
  end

  def self.find_or_create_role(name, description = nil, resource_type = nil, resource_id = nil)
    Role.find_or_create_by!(
      name: name.strip.downcase,
      resource_type: resource_type,
      resource_id: resource_id
    ) do |role|
      role.description = description
    end
  end

  def self.find_role(name, resource_type = nil, resource_id = nil)
    role = Role.where(name: name.strip.downcase, resource_type: resource_type, resource_id: resource_id).first
    raise RoleNotFoundError, "Role '#{name}' not found" unless role
    role
  end

  def self.delete_role(name, resource_type = nil, resource_id = nil)
    role = find_role(name, resource_type, resource_id)
    role.destroy
  end

  def self.create_permission(name, description, resource_type = nil, resource_id = nil)
    Permission.create!(
      name: name,
      description: description,
      resource_type: resource_type,
      resource_id: resource_id
    )
  end

  def self.find_or_create_permission(name, description, resource_type = nil, resource_id = nil)
    Permission.find_or_create_by!(
      name: name.strip.downcase,
      resource_type: resource_type,
      resource_id: resource_id
    ) do |permission|
      permission.description = description
    end
  end

  def self.find_permission(name, resource_type = nil, resource_id = nil)
    permission = Permission.where(name: name.strip.downcase, resource_type: resource_type, resource_id: resource_id).first
    raise PermissionNotFoundError, "Permission '#{name}' not found" unless permission
    permission
  end

  def self.delete_permission(name, resource_type = nil, resource_id = nil)
    permission = find_permission(name, resource_type, resource_id)
    permission.destroy
  end

  def self.grant_permission_to_role(role_name, permission_name, resource_type = nil, resource_id = nil)
    role = find_role(role_name, resource_type, resource_id)
    permission = find_permission(permission_name, resource_type, resource_id)
    role.grant_permission(permission)
  end

  def self.revoke_permission_from_role(role_name, permission_name, resource_type = nil, resource_id = nil)
    role = find_role(role_name, resource_type, resource_id)
    permission = find_permission(permission_name, resource_type, resource_id)
    role.revoke_permission(permission)
  end

  def self.grant_role_to_user(user, role_name, resource_type = nil, resource_id = nil)
    user = find_user(user)
    role = find_role(role_name, resource_type, resource_id)
    user.grant_role(role)
  end

  def self.revoke_role_from_user(user, role_name, resource_type = nil, resource_id = nil)
    user = find_user(user)
    role = find_role(role_name, resource_type, resource_id)
    user.revoke_role(role)
  end

  def self.user_has_role?(user, role_name, resource_type = nil, resource_id = nil)
    user = find_user(user)
    user.has_role?(role_name, resource_type, resource_id)
  end

  def self.user_has_permission?(user, permission_name, resource_type = nil, resource_id = nil)
    user = find_user(user)
    user.has_permission?(permission_name, resource_type, resource_id)
  end

  def self.user_permissions(user, resource_type = nil, resource_id = nil)
    user = find_user(user)
    user.permissions_list(resource_type, resource_id)
  end

  def self.user_roles(user, resource_type = nil, resource_id = nil)
    user = find_user(user)
    user.roles_list(resource_type, resource_id)
  end

  private

  def self.find_user(user)
    case user
    when User
      user
    when Integer
      User.find(user)
    when String
      User.find_by(email_address: user) || User.find(user)
    else
      raise ArgumentError, "Invalid user argument: #{user.inspect}"
    end
  end
end
