# frozen_string_literal: true

FactoryBot.define do
  factory :role_permission do
    association :role
    association :permission
  end
end
