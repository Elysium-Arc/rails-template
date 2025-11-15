# frozen_string_literal: true

class UserRole < ApplicationRecord
  audited

  # Associations
  belongs_to :user
  belongs_to :role

  # Validations
  validates :user_id, uniqueness: { scope: :role_id }

  # Callbacks
  after_create :clear_user_permission_cache
  after_destroy :clear_user_permission_cache

  private

  def clear_user_permission_cache
    # Clear any cached permissions for the user
    Rails.cache.delete("user_#{user_id}_permissions")
  end
end
