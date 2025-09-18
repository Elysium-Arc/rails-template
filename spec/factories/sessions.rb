# frozen_string_literal: true

FactoryBot.define do
  factory :session do
    association :user
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { Faker::Internet.user_agent }

    trait :recent do
      updated_at { 5.minutes.ago }
    end

    trait :idle do
      updated_at { 12.hours.ago }
    end

    trait :old do
      updated_at { 2.days.ago }
    end
  end
end
