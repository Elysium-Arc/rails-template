class Permission < ApplicationRecord
  audited
  include Hashid::Rails

  has_many :role_permissions, dependent: :destroy
  has_many :roles, through: :role_permissions

  normalizes :name, with: ->(n) { n.strip.downcase }

  validates :name, presence: true, uniqueness: { scope: [:resource_type, :resource_id], message: :taken }
  validates :description, presence: true, length: { maximum: 1000 }

  scope :global, -> { where(resource_type: nil, resource_id: nil) }
  scope :scoped_to, ->(resource_type, resource_id) { where(resource_type: resource_type, resource_id: resource_id) }
  scope :by_name, ->(name) { where(name: name.strip.downcase) }

  def global?
    resource_type.nil? && resource_id.nil?
  end

  def scoped?
    !global?
  end

  def to_key
    [hashid]
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id name description resource_type resource_id created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[roles]
  end
end
