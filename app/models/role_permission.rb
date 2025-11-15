# frozen_string_literal: true

class RolePermission < ApplicationRecord
  audited

  # Associations
  belongs_to :role
  belongs_to :permission

  # Validations
  validates :role_id, uniqueness: { scope: :permission_id }
end
