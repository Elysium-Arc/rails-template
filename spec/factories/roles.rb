# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Description for #{name}" }
    resource_type { nil }
    resource_id { nil }

    trait :global do
      resource_type { nil }
      resource_id { nil }
    end

    trait :scoped do
      resource_type { "User" }
      resource_id { 1 }
    end

    trait :admin do
      name { "admin" }
      description { "Administrator role" }
    end

    trait :super_admin do
      name { "super_admin" }
      description { "Super administrator role" }
    end

    trait :manager do
      name { "manager" }
      description { "Manager role" }
    end

    trait :user do
      name { "user" }
      description { "Standard user role" }
    end

    trait :with_permissions do
      transient do
        permissions_count { 3 }
      end

      after(:create) do |role, evaluator|
        create_list(:permission, evaluator.permissions_count, roles: [role])
      end
    end
  end
end
