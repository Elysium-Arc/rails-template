namespace :rbac do
  desc 'Seed default roles and permissions'
  task seed: :environment do
    puts 'Seeding default roles and permissions...'
    Seeding::RbacService.seed_default_roles_and_permissions
    puts 'Seeding complete!'
  end

  namespace :role do
    desc 'Create a new role - usage: rails rbac:role:create[name,"description"]'
    task :create, [:name, :description] => :environment do |t, args|
      name = args[:name]
      description = args[:description] || "Role: #{name}"

      if name.blank?
        puts 'Usage: rails rbac:role:create[name,"description"]'
        next
      end

      role = RbacService.create_role(name, description)
      puts "Created role: #{role.name}"
    end

    desc 'Delete a role - usage: rails rbac:role:delete[name]'
    task :delete, [:name] => :environment do |t, args|
      name = args[:name]

      if name.blank?
        puts 'Usage: rails rbac:role:delete[name]'
        next
      end

      begin
        RbacService.delete_role(name)
        puts "Deleted role: #{name}"
      rescue RbacService::RoleNotFoundError => e
        puts "Error: #{e.message}"
      end
    end

    desc 'List all roles'
    task list: :environment do
      roles = Role.all
      if roles.empty?
        puts 'No roles found'
        next
      end

      puts "\nGlobal Roles:"
      Role.global.each do |role|
        puts "  - #{role.name} (#{role.permissions.count} permissions)"
      end

      scoped = Role.where.not(resource_type: nil)
      if scoped.any?
        puts "\nScoped Roles:"
        scoped.each do |role|
          puts "  - #{role.name} [#{role.resource_type}:#{role.resource_id}] (#{role.permissions.count} permissions)"
        end
      end
    end
  end

  namespace :permission do
    desc 'Create a new permission - usage: rails rbac:permission:create[name,"description"]'
    task :create, [:name, :description] => :environment do |t, args|
      name = args[:name]
      description = args[:description]

      if name.blank? || description.blank?
        puts 'Usage: rails rbac:permission:create[name,"description"]'
        next
      end

      permission = RbacService.create_permission(name, description)
      puts "Created permission: #{permission.name}"
    end

    desc 'Delete a permission - usage: rails rbac:permission:delete[name]'
    task :delete, [:name] => :environment do |t, args|
      name = args[:name]

      if name.blank?
        puts 'Usage: rails rbac:permission:delete[name]'
        next
      end

      begin
        RbacService.delete_permission(name)
        puts "Deleted permission: #{name}"
      rescue RbacService::PermissionNotFoundError => e
        puts "Error: #{e.message}"
      end
    end

    desc 'List all permissions'
    task list: :environment do
      permissions = Permission.all
      if permissions.empty?
        puts 'No permissions found'
        next
      end

      puts "\nGlobal Permissions:"
      Permission.global.each do |perm|
        puts "  - #{perm.name}: #{perm.description}"
      end

      scoped = Permission.where.not(resource_type: nil)
      if scoped.any?
        puts "\nScoped Permissions:"
        scoped.each do |perm|
          puts "  - #{perm.name} [#{perm.resource_type}:#{perm.resource_id}]: #{perm.description}"
        end
      end
    end
  end

  namespace :grant do
    desc 'Grant permission to role - usage: rails rbac:grant:permission[role_name,permission_name]'
    task :permission, [:role_name, :permission_name] => :environment do |t, args|
      role_name = args[:role_name]
      permission_name = args[:permission_name]

      if role_name.blank? || permission_name.blank?
        puts 'Usage: rails rbac:grant:permission[role_name,permission_name]'
        next
      end

      begin
        RbacService.grant_permission_to_role(role_name, permission_name)
        puts "Granted #{permission_name} to #{role_name}"
      rescue RbacService::RoleNotFoundError, RbacService::PermissionNotFoundError => e
        puts "Error: #{e.message}"
      end
    end

    desc 'Grant role to user - usage: rails rbac:grant:role[email,role_name]'
    task :role, [:email, :role_name] => :environment do |t, args|
      email = args[:email]
      role_name = args[:role_name]

      if email.blank? || role_name.blank?
        puts 'Usage: rails rbac:grant:role[email,role_name]'
        next
      end

      user = User.find_by(email_address: email)
      unless user
        puts "Error: User with email #{email} not found"
        next
      end

      begin
        RbacService.grant_role_to_user(user, role_name)
        puts "Granted #{role_name} role to #{email}"
      rescue RbacService::RoleNotFoundError => e
        puts "Error: #{e.message}"
      end
    end
  end

  namespace :revoke do
    desc 'Revoke permission from role - usage: rails rbac:revoke:permission[role_name,permission_name]'
    task :permission, [:role_name, :permission_name] => :environment do |t, args|
      role_name = args[:role_name]
      permission_name = args[:permission_name]

      if role_name.blank? || permission_name.blank?
        puts 'Usage: rails rbac:revoke:permission[role_name,permission_name]'
        next
      end

      begin
        RbacService.revoke_permission_from_role(role_name, permission_name)
        puts "Revoked #{permission_name} from #{role_name}"
      rescue RbacService::RoleNotFoundError, RbacService::PermissionNotFoundError => e
        puts "Error: #{e.message}"
      end
    end

    desc 'Revoke role from user - usage: rails rbac:revoke:role[email,role_name]'
    task :role, [:email, :role_name] => :environment do |t, args|
      email = args[:email]
      role_name = args[:role_name]

      if email.blank? || role_name.blank?
        puts 'Usage: rails rbac:revoke:role[email,role_name]'
        next
      end

      user = User.find_by(email_address: email)
      unless user
        puts "Error: User with email #{email} not found"
        next
      end

      begin
        RbacService.revoke_role_from_user(user, role_name)
        puts "Revoked #{role_name} role from #{email}"
      rescue RbacService::RoleNotFoundError => e
        puts "Error: #{e.message}"
      end
    end
  end

  namespace :user do
    desc 'Show user roles and permissions - usage: rails rbac:user:show[email]'
    task :show, [:email] => :environment do |t, args|
      email = args[:email]

      if email.blank?
        puts 'Usage: rails rbac:user:show[email]'
        next
      end

      user = User.find_by(email_address: email)
      unless user
        puts "Error: User with email #{email} not found"
        next
      end

      puts "\nUser: #{user.email_address}"
      puts "\nRoles:"
      if user.roles.any?
        user.roles.each { |r| puts "  - #{r.name}" }
      else
        puts "  (none)"
      end

      puts "\nPermissions:"
      permissions = user.roles.joins(:permissions).pluck('permissions.name').uniq
      if permissions.any?
        permissions.each { |p| puts "  - #{p}" }
      else
        puts "  (none)"
      end
    end
  end
end
