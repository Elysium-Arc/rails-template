class Role < ApplicationRecord
  audited
  include Hashid::Rails

  has_many :role_permissions, dependent: :destroy
  has_many :permissions, through: :role_permissions
  has_many :user_roles, dependent: :destroy
  has_many :users, through: :user_roles

  normalizes :name, with: ->(n) { n.strip.downcase }

  validates :name, presence: true, uniqueness: { scope: [:resource_type, :resource_id], message: :taken }
  validates :description, length: { maximum: 1000 }, allow_blank: true

  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :scoped_to, ->(resource_type, resource_id) { where(resource_type: resource_type, resource_id: resource_id) }
  scope :by_name, ->(name) { where(name: name.strip.downcase) }

  def global?
    resource_type.nil? && resource_id.nil?
  end

  def scoped?
    !global?
  end

  def grant_permission(permission)
    permissions << permission unless permissions.include?(permission)
  end

  def revoke_permission(permission)
    permissions.delete(permission)
  end

  def has_permission?(permission_name, resource_type = nil, resource_id = nil)
    permissions.exists?(name: permission_name, resource_type: resource_type, resource_id: resource_id)
  end

  def to_key
    [hashid]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name resource_type resource_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[permissions users]
  end
end
