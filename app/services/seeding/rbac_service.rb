# frozen_string_literal: true

module Seeding
  class RbacService
    def self.seed_default_roles_and_permissions
      create_admin_role
      create_default_roles
      create_default_permissions
      grant_permissions_to_roles
    end

    private

    def self.create_admin_role
      RbacService.find_or_create_role(
        'admin',
        'Administrator with full system access'
      )
    end

    def self.create_default_roles
      RbacService.find_or_create_role(
        'user',
        'Regular user with basic access'
      )

      RbacService.find_or_create_role(
        'manager',
        'Manager with elevated permissions'
      )

      RbacService.find_or_create_role(
        'moderator',
        'Content moderator'
      )

      RbacService.find_or_create_role(
        'viewer',
        'Read-only access'
      )
    end

    def self.create_default_permissions
      permissions = {
        'user.create' => 'Create new users',
        'user.read' => 'View user information',
        'user.update' => 'Update user information',
        'user.delete' => 'Delete users',
        'user.list' => 'List all users',
        'user.manage_roles' => 'Manage user roles and permissions',

        'role.create' => 'Create new roles',
        'role.read' => 'View role information',
        'role.update' => 'Update role information',
        'role.delete' => 'Delete roles',
        'role.list' => 'List all roles',
        'role.manage_permissions' => 'Manage role permissions',

        'permission.create' => 'Create new permissions',
        'permission.read' => 'View permission information',
        'permission.update' => 'Update permission information',
        'permission.delete' => 'Delete permissions',
        'permission.list' => 'List all permissions',

        'dashboard.access' => 'Access the dashboard',
        'admin.access' => 'Access admin panel',
        'audit.read' => 'View audit logs',

        'content.create' => 'Create content',
        'content.read' => 'View content',
        'content.update' => 'Update content',
        'content.delete' => 'Delete content',
        'content.publish' => 'Publish content',
        'content.moderate' => 'Moderate content'
      }

      permissions.each do |name, description|
        RbacService.find_or_create_permission(name, description)
      end
    end

    def self.grant_permissions_to_roles
      admin_permissions = [
        'user.create', 'user.read', 'user.update', 'user.delete', 'user.list', 'user.manage_roles',
        'role.create', 'role.read', 'role.update', 'role.delete', 'role.list', 'role.manage_permissions',
        'permission.create', 'permission.read', 'permission.update', 'permission.delete', 'permission.list',
        'dashboard.access', 'admin.access', 'audit.read',
        'content.create', 'content.read', 'content.update', 'content.delete', 'content.publish', 'content.moderate'
      ]

      admin_role = RbacService.find_role('admin')
      admin_permissions.each do |permission_name|
        permission = Permission.find_by(name: permission_name)
        admin_role.grant_permission(permission) if permission
      end

      manager_permissions = [
        'user.read', 'user.update', 'user.list',
        'role.read', 'role.list',
        'permission.read', 'permission.list',
        'dashboard.access', 'audit.read',
        'content.create', 'content.read', 'content.update', 'content.delete', 'content.publish', 'content.moderate'
      ]

      manager_role = RbacService.find_role('manager')
      manager_permissions.each do |permission_name|
        permission = Permission.find_by(name: permission_name)
        manager_role.grant_permission(permission) if permission
      end

      moderator_permissions = [
        'user.read', 'user.list',
        'dashboard.access',
        'content.read', 'content.moderate'
      ]

      moderator_role = RbacService.find_role('moderator')
      moderator_permissions.each do |permission_name|
        permission = Permission.find_by(name: permission_name)
        moderator_role.grant_permission(permission) if permission
      end

      user_permissions = [
        'user.read', 'user.update',
        'dashboard.access',
        'content.read', 'content.create'
      ]

      user_role = RbacService.find_role('user')
      user_permissions.each do |permission_name|
        permission = Permission.find_by(name: permission_name)
        user_role.grant_permission(permission) if permission
      end

      viewer_permissions = [
        'dashboard.access',
        'content.read'
      ]

      viewer_role = RbacService.find_role('viewer')
      viewer_permissions.each do |permission_name|
        permission = Permission.find_by(name: permission_name)
        viewer_role.grant_permission(permission) if permission
      end
    end
  end
end
