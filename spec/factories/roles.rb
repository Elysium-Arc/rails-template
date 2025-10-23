# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Test role description" }
    resource_type { nil }
    resource_id { nil }

    trait :admin do
      name { "admin" }
      description { "Administrator role with full access" }
    end

    trait :user do
      name { "user" }
      description { "Standard user role" }
    end

    trait :moderator do
      name { "moderator" }
      description { "Moderator role with limited admin access" }
    end

    trait :with_permissions do
      transient do
        permissions_count { 3 }
      end

      after(:create) do |role, evaluator|
        create_list(:permission, evaluator.permissions_count, roles: [role])
      end
    end

    trait :with_users do
      transient do
        users_count { 2 }
      end

      after(:create) do |role, evaluator|
        create_list(:user, evaluator.users_count, roles: [role])
      end
    end
  end
end
