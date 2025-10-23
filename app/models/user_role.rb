# frozen_string_literal: true

class UserRole < ApplicationRecord
  audited

  # Associations
  belongs_to :user
  belongs_to :role

  # Validations
  validates :user_id, uniqueness: { scope: :role_id }

  # Ensure user has at least one role after destruction
  # This can be customized based on application needs
  # For now, we allow users with no roles
end
