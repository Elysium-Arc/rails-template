module Rbac
  extend ActiveSupport::Concern

  included do
    has_many :user_roles, dependent: :destroy
    has_many :roles, through: :user_roles
  end

  def has_role?(role_name, resource_type = nil, resource_id = nil)
    if resource_type.present?
      roles.exists?(
        name: role_name.to_s.strip.downcase,
        resource_type: resource_type,
        resource_id: resource_id
      )
    else
      roles.where(name: role_name.to_s.strip.downcase)
        .where(resource_type: nil, resource_id: nil)
        .exists?
    end
  end

  def has_permission?(permission_name, resource_type = nil, resource_id = nil)
    roles.joins(:permissions).exists?(
      permissions: {
        name: permission_name.to_s.strip.downcase,
        resource_type: resource_type,
        resource_id: resource_id
      }
    )
  end

  def has_any_permission?(permission_names, resource_type = nil, resource_id = nil)
    permission_names = Array(permission_names).map { |p| p.to_s.strip.downcase }
    roles.joins(:permissions).where(permissions: { name: permission_names, resource_type: resource_type, resource_id: resource_id }).exists?
  end

  def has_all_permissions?(permission_names, resource_type = nil, resource_id = nil)
    permission_names = Array(permission_names).map { |p| p.to_s.strip.downcase }
    permission_names.all? { |perm| has_permission?(perm, resource_type, resource_id) }
  end

  def grant_role(role)
    roles << role unless roles.include?(role)
  end

  def revoke_role(role)
    roles.delete(role)
  end

  def admin?
    has_role?('admin')
  end

  def roles_list(resource_type = nil, resource_id = nil)
    if resource_type.present?
      roles.where(resource_type: resource_type, resource_id: resource_id).pluck(:name)
    else
      roles.where(resource_type: nil, resource_id: nil).pluck(:name)
    end
  end

  def permissions_list(resource_type = nil, resource_id = nil)
    roles.joins(:permissions)
      .where(permissions: { resource_type: resource_type, resource_id: resource_id })
      .pluck('permissions.name')
      .uniq
  end
end
