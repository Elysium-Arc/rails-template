# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "permission_#{n}" }
    description { "Test permission description" }
    resource_type { nil }
    resource_id { nil }

    trait :users_index do
      name { "users.index" }
      description { "View users list" }
    end

    trait :users_create do
      name { "users.create" }
      description { "Create new users" }
    end

    trait :users_update do
      name { "users.update" }
      description { "Update existing users" }
    end

    trait :users_destroy do
      name { "users.destroy" }
      description { "Delete users" }
    end

    trait :roles_manage do
      name { "roles.manage" }
      description { "Manage roles" }
    end

    trait :permissions_manage do
      name { "permissions.manage" }
      description { "Manage permissions" }
    end

    trait :with_roles do
      transient do
        roles_count { 2 }
      end

      after(:create) do |permission, evaluator|
        create_list(:role, evaluator.roles_count, permissions: [permission])
      end
    end
  end
end
