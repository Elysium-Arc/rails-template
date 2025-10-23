# frozen_string_literal: true

FactoryBot.define do
  factory :role_permission do
    role
    permission
  end
end
