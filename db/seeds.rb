# frozen_string_literal: true

puts "Seeding data for #{ENV.fetch("RAILS_ENV", "development")} environment".upcase

# Seed RBAC system (roles and permissions)
puts "\n=== Seeding RBAC System ==="
Seeding::RbacSeeder.seed!

# Create admin user from environment variables
if User.count.zero? && ENV["ADMIN_EMAIL_ADDRESS"].present? && ENV["ADMIN_PASSWORD"].present?
  user = Seeding::UserService.create_user(ENV.fetch("ADMIN_EMAIL_ADDRESS"), ENV.fetch("ADMIN_PASSWORD"))
  # Assign super_admin role to the admin user
  if user && (role = Role.find_by(name: "super_admin"))
    user.add_role("super_admin")
    puts "✓ Assigned super_admin role to #{user.email_address}"
  end
end

# Seed test data for development environment
if Rails.env.development?
  require 'factory_bot_rails'

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

    test_users.each_with_index do |user_data, index|
      next if User.exists?(email_address: user_data[:email])

      user = FactoryBot.create(:user,
        email_address: user_data[:email],
        password: user_data[:password],
        password_confirmation: user_data[:password]
      )
      puts "Created test user: #{user_data[:email]}"

      # Assign roles to test users
      case index
      when 0
        user.add_role("user")
      when 1
        user.add_role("manager")
      when 2
        user.add_role("admin")
      end
    end

    puts "Successfully created #{User.count} users with sessions"
  else
    puts "Users already exist. Skipping seed creation."
  end
end

puts "Seeding completed!"
