# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}".downcase }
    description { "Description for #{name}" }
    resource_type { nil }
    resource_id { nil }

    trait :admin do
      name { 'admin' }
      description { 'Administrator role with full access' }
    end

    trait :user do
      name { 'user' }
      description { 'Regular user role' }
    end

    trait :scoped do
      resource_type { 'Project' }
      resource_id { 1 }
    end
  end
end
