# frozen_string_literal: true

puts "Seeding data for #{ENV.fetch("RAILS_ENV", "development")} environment".upcase

# Create default roles and permissions
puts "Creating default roles and permissions..."

# Create permissions
permissions = [
  { name: 'users.index', description: 'View users list' },
  { name: 'users.show', description: 'View user details' },
  { name: 'users.create', description: 'Create new users' },
  { name: 'users.update', description: 'Update existing users' },
  { name: 'users.destroy', description: 'Delete users' },
  { name: 'roles.index', description: 'View roles list' },
  { name: 'roles.show', description: 'View role details' },
  { name: 'roles.create', description: 'Create new roles' },
  { name: 'roles.update', description: 'Update existing roles' },
  { name: 'roles.destroy', description: 'Delete roles' },
  { name: 'permissions.index', description: 'View permissions list' },
  { name: 'permissions.show', description: 'View permission details' },
  { name: 'permissions.create', description: 'Create new permissions' },
  { name: 'permissions.update', description: 'Update existing permissions' },
  { name: 'permissions.destroy', description: 'Delete permissions' }
]

permissions.each do |perm_data|
  Permission.find_or_create_by!(name: perm_data[:name]) do |permission|
    permission.description = perm_data[:description]
  end
end

puts "Created #{Permission.count} permissions"

# Create roles
admin_role = Role.find_or_create_by!(name: 'admin') do |role|
  role.description = 'Administrator role with full access to all features'
end

user_role = Role.find_or_create_by!(name: 'user') do |role|
  role.description = 'Standard user role with basic access'
end

moderator_role = Role.find_or_create_by!(name: 'moderator') do |role|
  role.description = 'Moderator role with limited administrative access'
end

puts "Created #{Role.count} roles"

# Assign all permissions to admin role
admin_role.permissions = Permission.all
puts "Assigned all permissions to admin role"

# Assign limited permissions to user role
user_permissions = Permission.where(name: ['users.show', 'users.update'])
user_role.permissions = user_permissions
puts "Assigned #{user_permissions.count} permissions to user role"

# Assign moderate permissions to moderator role
moderator_permissions = Permission.where(name: ['users.index', 'users.show', 'users.create', 'users.update'])
moderator_role.permissions = moderator_permissions
puts "Assigned #{moderator_permissions.count} permissions to moderator role"

# Create admin user from environment variables
if User.count.zero? && ENV["ADMIN_EMAIL_ADDRESS"].present? && ENV["ADMIN_PASSWORD"].present?
  admin_user = Seeding::UserService.create_user(ENV.fetch("ADMIN_EMAIL_ADDRESS"), ENV.fetch("ADMIN_PASSWORD"))
  admin_user.roles << admin_role unless admin_user.roles.include?(admin_role)
  puts "Created admin user with admin role"
end

# Seed test data for development environment
if Rails.env.development?
  require 'factory_bot_rails'

  # Load factory definitions
  FactoryBot.find_definitions

  # Create test users if needed
  if User.count < 20
    puts "Creating test users with FactoryBot..."

    # Create users with different states
    5.times do |i|
      FactoryBot.create(:user, email_address: "user#{i + 1}@example.com")
    end

    # Create active users (with recent sessions)
    3.times do |i|
      FactoryBot.create(:user, :active, email_address: "active#{i + 1}@example.com")
    end

    # Create idle users (with idle sessions)
    3.times do |i|
      FactoryBot.create(:user, :idle, email_address: "idle#{i + 1}@example.com")
    end

    # Create users with multiple sessions
    2.times do |i|
      FactoryBot.create(:user, :with_sessions, email_address: "multi_session#{i + 1}@example.com")
    end

    # Create specific test users
    test_users = [
      { email: "john.doe@example.com", password: "password123" },
      { email: "jane.smith@example.com", password: "password123" },
      { email: "admin@example.com", password: "password123" }
    ]

    test_users.each do |user_data|
      next if User.exists?(email_address: user_data[:email])

      FactoryBot.create(:user,
        email_address: user_data[:email],
        password: user_data[:password],
        password_confirmation: user_data[:password]
      )
      puts "Created test user: #{user_data[:email]}"
    end

    puts "Successfully created #{User.count} users with sessions"
  else
    puts "Users already exist. Skipping seed creation."
  end
end

puts "Seeding completed!"
