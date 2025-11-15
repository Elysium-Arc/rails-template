# frozen_string_literal: true

module Seeding
  class RbacSeeder
    def self.seed!
      new.seed!
    end

    def seed!
      create_permissions
      create_roles
      assign_permissions_to_roles
    end

    private

    def create_permissions
      puts "Creating permissions..."

      permissions_data.each do |perm_data|
        Permission.find_or_create_by!(
          name: perm_data[:name],
          resource_type: perm_data[:resource_type],
          resource_id: perm_data[:resource_id]
        ) do |permission|
          permission.description = perm_data[:description]
        end
      end

      puts "✓ Created #{Permission.count} permissions"
    end

    def create_roles
      puts "Creating roles..."

      roles_data.each do |role_data|
        Role.find_or_create_by!(name: role_data[:name]) do |role|
          role.description = role_data[:description]
        end
      end

      puts "✓ Created #{Role.count} roles"
    end

    def assign_permissions_to_roles
      puts "Assigning permissions to roles..."

      role_permissions_mapping.each do |role_name, permission_names|
        role = Role.find_by(name: role_name)
        next unless role

        permission_names.each do |perm_name|
          permission = Permission.find_by(name: perm_name, resource_type: nil)
          next unless permission

          RolePermission.find_or_create_by!(role: role, permission: permission)
        end
      end

      puts "✓ Assigned permissions to roles"
    end

    def permissions_data
      [
        # User permissions
        { name: "users.index", description: "View list of users", resource_type: nil, resource_id: nil },
        { name: "users.show", description: "View user details", resource_type: nil, resource_id: nil },
        { name: "users.create", description: "Create new users", resource_type: nil, resource_id: nil },
        { name: "users.update", description: "Update user information", resource_type: nil, resource_id: nil },
        { name: "users.destroy", description: "Delete users", resource_type: nil, resource_id: nil },
        { name: "users.manage", description: "Full management of users", resource_type: nil, resource_id: nil },
        { name: "users.assign_roles", description: "Assign roles to users", resource_type: nil, resource_id: nil },

        # Role permissions
        { name: "roles.index", description: "View list of roles", resource_type: nil, resource_id: nil },
        { name: "roles.show", description: "View role details", resource_type: nil, resource_id: nil },
        { name: "roles.create", description: "Create new roles", resource_type: nil, resource_id: nil },
        { name: "roles.update", description: "Update role information", resource_type: nil, resource_id: nil },
        { name: "roles.destroy", description: "Delete roles", resource_type: nil, resource_id: nil },
        { name: "roles.manage", description: "Full management of roles", resource_type: nil, resource_id: nil },
        { name: "roles.assign_permissions", description: "Assign permissions to roles", resource_type: nil, resource_id: nil },

        # Permission permissions
        { name: "permissions.index", description: "View list of permissions", resource_type: nil, resource_id: nil },
        { name: "permissions.show", description: "View permission details", resource_type: nil, resource_id: nil },
        { name: "permissions.create", description: "Create new permissions", resource_type: nil, resource_id: nil },
        { name: "permissions.update", description: "Update permission information", resource_type: nil, resource_id: nil },
        { name: "permissions.destroy", description: "Delete permissions", resource_type: nil, resource_id: nil },
        { name: "permissions.manage", description: "Full management of permissions", resource_type: nil, resource_id: nil },

        # Dashboard permissions
        { name: "dashboard.view", description: "View dashboard", resource_type: nil, resource_id: nil },
        { name: "dashboard.analytics", description: "View analytics on dashboard", resource_type: nil, resource_id: nil },

        # Audit permissions
        { name: "audits.view", description: "View audit logs", resource_type: nil, resource_id: nil },
        { name: "audits.export", description: "Export audit logs", resource_type: nil, resource_id: nil },

        # Settings permissions
        { name: "settings.view", description: "View application settings", resource_type: nil, resource_id: nil },
        { name: "settings.update", description: "Update application settings", resource_type: nil, resource_id: nil }
      ]
    end

    def roles_data
      [
        {
          name: "super_admin",
          description: "Super administrator with full system access and ability to manage all aspects of the system including permissions"
        },
        {
          name: "admin",
          description: "Administrator with full access to manage users, roles, and most system features"
        },
        {
          name: "manager",
          description: "Manager with ability to view and manage users and their own resources"
        },
        {
          name: "user",
          description: "Standard user with basic access to view and manage their own data"
        },
        {
          name: "viewer",
          description: "Read-only user with view access to permitted resources"
        }
      ]
    end

    def role_permissions_mapping
      {
        "super_admin" => [
          # All permissions
          "users.index", "users.show", "users.create", "users.update", "users.destroy", "users.manage", "users.assign_roles",
          "roles.index", "roles.show", "roles.create", "roles.update", "roles.destroy", "roles.manage", "roles.assign_permissions",
          "permissions.index", "permissions.show", "permissions.create", "permissions.update", "permissions.destroy", "permissions.manage",
          "dashboard.view", "dashboard.analytics",
          "audits.view", "audits.export",
          "settings.view", "settings.update"
        ],
        "admin" => [
          # User management
          "users.index", "users.show", "users.create", "users.update", "users.destroy", "users.assign_roles",
          # Role viewing and assignment
          "roles.index", "roles.show", "roles.assign_permissions",
          # Permission viewing
          "permissions.index", "permissions.show",
          # Dashboard and audits
          "dashboard.view", "dashboard.analytics",
          "audits.view",
          # Settings viewing
          "settings.view"
        ],
        "manager" => [
          # User viewing and basic management
          "users.index", "users.show",
          # Dashboard access
          "dashboard.view",
          # Limited role viewing
          "roles.index", "roles.show"
        ],
        "user" => [
          # Basic dashboard access
          "dashboard.view",
          # Can view their own user info (enforced in policy)
          "users.show"
        ],
        "viewer" => [
          # Read-only access
          "dashboard.view",
          "users.show"
        ]
      }
    end
  end
end
