# frozen_string_literal: true

class Role < ApplicationRecord
  audited

  # Associations
  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  # For scoped/resource-specific roles (e.g., Admin of Organization #1)
  belongs_to :resource, polymorphic: true, optional: true

  # Validations
  validates :name, presence: true, uniqueness: { scope: [:resource_type, :resource_id] }
  validates :name, format: { with: /\A[a-z_]+\z/, message: "must be lowercase with underscores only" }

  # Scopes
  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :scoped_to, ->(resource) { where(resource_type: resource.class.name, resource_id: resource.id) }

  # Check if role has a specific permission
  def has_permission?(permission_name, resource = nil)
    permissions.where(
      name: permission_name,
      resource_type: resource&.class&.name || nil,
      resource_id: resource&.id || nil
    ).exists?
  end

  # Check if role is global (not scoped to a resource)
  def global?
    resource_type.nil? && resource_id.nil?
  end

  # Check if role is scoped to a resource
  def scoped?
    !global?
  end

  # Display name for the role
  def display_name
    name.humanize
  end

  # Full display name including resource if scoped
  def full_display_name
    if scoped?
      "#{display_name} (#{resource_type} ##{resource_id})"
    else
      display_name
    end
  end
end
