FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "permission_#{n}".downcase }
    description { "Description for #{name}" }
    resource_type { nil }
    resource_id { nil }

    trait :global do
      resource_type { nil }
      resource_id { nil }
    end

    trait :scoped do
      resource_type { 'Post' }
      resource_id { 1 }
    end
  end
end
