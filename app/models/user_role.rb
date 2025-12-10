# frozen_string_literal: true

class UserRole < ApplicationRecord
  audited

  belongs_to :user
  belongs_to :role

  validates :user_id, uniqueness: { scope: :role_id, message: :already_has_role }
end
