# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    trait :admin do
      email_address { "admin@example.com" }
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
