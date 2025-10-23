# frozen_string_literal: true

class Role < ApplicationRecord
  audited
  include Hashid::Rails

  # Associations
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions

  # Validations
  validates :name, presence: true,
                   uniqueness: { scope: [:resource_type, :resource_id], case_sensitive: false }
  validates :description, length: { maximum: 500 }

  # Scopes
  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :resource_specific, ->(resource_type, resource_id = nil) {
    where(resource_type: resource_type).tap do |scope|
      scope.where!(resource_id: resource_id) if resource_id
    end
  }

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[id name description resource_type resource_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[users permissions]
  end

  # Check if role has a specific permission
  def has_permission?(permission_name)
    permissions.exists?(name: permission_name)
  end

  # Add permission to role
  def add_permission(permission)
    permissions << permission unless has_permission?(permission.name)
  end

  # Remove permission from role
  def remove_permission(permission)
    permissions.delete(permission)
  end

  # Check if this is a global role (not resource-specific)
  def global?
    resource_type.nil? && resource_id.nil?
  end

  def to_key
    [hashid]
  end
end
