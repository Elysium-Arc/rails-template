# frozen_string_literal: true

class Permission < ApplicationRecord
  audited
  include Hashid::Rails

  # Associations
  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  # Validations
  validates :name, presence: true,
                   uniqueness: { scope: [:resource_type, :resource_id], case_sensitive: false }
  validates :description, presence: true, length: { maximum: 500 }

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
    %w[roles]
  end

  # Check if this is a global permission (not resource-specific)
  def global?
    resource_type.nil? && resource_id.nil?
  end

  def to_key
    [hashid]
  end
end
