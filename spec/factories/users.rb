# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :admin do
      email_address { "admin@example.com" }

      after(:create) do |user|
        admin_role = Role.find_or_create_by!(name: "admin") do |role|
          role.description = "Administrator role with full access"
        end
        user.roles << admin_role unless user.roles.include?(admin_role)
      end
    end

    trait :with_role do
      transient do
        role_name { "user" }
      end

      after(:create) do |user, evaluator|
        role = Role.find_or_create_by!(name: evaluator.role_name) do |r|
          r.description = "#{evaluator.role_name.titleize} role"
        end
        user.roles << role unless user.roles.include?(role)
      end
    end

    trait :with_roles do
      transient do
        roles_count { 2 }
      end

      after(:create) do |user, evaluator|
        create_list(:role, evaluator.roles_count, users: [ user ])
      end
    end

    trait :with_sessions do
      after(:create) do |user|
        create_list(:session, 3, user: user)
      end
    end

    trait :active do
      after(:create) do |user|
        create(:session, user: user, updated_at: 10.minutes.ago)
      end
    end

    trait :idle do
      after(:create) do |user|
        create(:session, user: user, updated_at: 12.hours.ago)
      end
    end

    trait :inactive do
      # No sessions or very old sessions
    end
  end
end
