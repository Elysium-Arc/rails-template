# frozen_string_literal: true

class RolePermission < ApplicationRecord
  audited

  belongs_to :role
  belongs_to :permission

  validates :role_id, uniqueness: { scope: :permission_id, message: :already_has_permission }
end
