# frozen_string_literal: true

FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "permission_#{n}" }
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

    trait :users_index do
      name { "users.index" }
      description { "View list of users" }
    end

    trait :users_create do
      name { "users.create" }
      description { "Create new users" }
    end

    trait :users_manage do
      name { "users.manage" }
      description { "Full management of users" }
    end
  end
end
