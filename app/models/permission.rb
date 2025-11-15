# frozen_string_literal: true

class Permission < ApplicationRecord
  audited

  # Associations
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  # For scoped/resource-specific permissions
  belongs_to :resource, polymorphic: true, optional: true

  # Validations
  validates :name, presence: true, uniqueness: { scope: [:resource_type, :resource_id] }
  validates :name, format: { with: /\A[a-z_\.]+\z/, message: "must be lowercase with underscores or dots only" }
  validates :description, presence: true

  # Scopes
  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :scoped_to, ->(resource) { where(resource_type: resource.class.name, resource_id: resource.id) }
  scope :by_resource_type, ->(type) { where(resource_type: type) }

  # Check if permission is global (not scoped to a resource)
  def global?
    resource_type.nil? && resource_id.nil?
  end

  # Check if permission is scoped to a resource
  def scoped?
    !global?
  end

  # Display name for the permission
  def display_name
    name.humanize
  end

  # Extract action and subject from permission name (e.g., "users.create" -> ["create", "users"])
  def action_and_subject
    parts = name.split(".")
    if parts.length == 2
      [parts.last, parts.first]
    else
      [name, "general"]
    end
  end
end
