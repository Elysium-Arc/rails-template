# frozen_string_literal: true

puts "Seeding data for #{ENV.fetch("RAILS_ENV", "development")} environment".upcase

# Create admin user from environment variables
if User.count.zero? && ENV["ADMIN_EMAIL_ADDRESS"].present? && ENV["ADMIN_PASSWORD"].present?
  Seeding::UserService.create_user(ENV.fetch("ADMIN_EMAIL_ADDRESS"), ENV.fetch("ADMIN_PASSWORD"))
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
