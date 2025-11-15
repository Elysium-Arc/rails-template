class User < ApplicationRecord
  audited
  include Hashid::Rails

  has_secure_password
  has_many :sessions, dependent: :destroy

  # RBAC associations
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles
  has_many :role_permissions, through: :roles
  has_many :permissions, through: :role_permissions

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  # Validations
  validates :email_address, presence: true,
                            uniqueness: { case_sensitive: false },
                            format: {
                              with: URI::MailTo::EMAIL_REGEXP,
                              message: :invalid_format
                            },
                            length: { maximum: 255 }

  validates :password, length: { minimum: 8, maximum: 255 }, if: :password_digest_changed?

  # Authenticate a user with the provided params (from permittted session params).
  # Returns the user on success, or a symbol describing the failure on failure.
  # Possible return values:
  # - User instance: successful authentication
  # - :user_not_found: no user with the provided email exists
  # - :invalid_password: email found but password doesn't match
  def self.authenticate_by(params)
    email = params[:email_address].to_s.strip.downcase
    password = params[:password].to_s

    user = find_by(email_address: email)
    return :user_not_found unless user

    return user if user.authenticate(password)

    :invalid_password
  end

  # Status based on session activity
  def status
    return "inactive" if sessions.empty?

    latest_session = sessions.order(updated_at: :desc).first
    if latest_session.updated_at > 30.minutes.ago
      "active"
    elsif latest_session.updated_at > 24.hours.ago
      "idle"
    else
      "inactive"
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[id email_address created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def to_key
    [ hashid ]
  end

  # RBAC methods

  # Assign a role to the user
  def add_role(role_name, resource = nil)
    role = if resource
             Role.find_by(name: role_name, resource: resource)
           else
             Role.find_by(name: role_name, resource_type: nil, resource_id: nil)
           end

    return false unless role

    user_roles.find_or_create_by(role: role)
    Rails.cache.delete("user_#{id}_permissions")
    true
  end

  # Remove a role from the user
  def remove_role(role_name, resource = nil)
    role = if resource
             Role.find_by(name: role_name, resource: resource)
           else
             Role.find_by(name: role_name, resource_type: nil, resource_id: nil)
           end

    return false unless role

    user_roles.find_by(role: role)&.destroy
    Rails.cache.delete("user_#{id}_permissions")
    true
  end

  # Check if user has a specific role
  def has_role?(role_name, resource = nil)
    if resource
      roles.exists?(name: role_name, resource: resource)
    else
      roles.exists?(name: role_name, resource_type: nil, resource_id: nil)
    end
  end

  # Check if user has any of the given roles
  def has_any_role?(*role_names)
    roles.where(name: role_names, resource_type: nil, resource_id: nil).exists?
  end

  # Check if user has all of the given roles
  def has_all_roles?(*role_names)
    role_names.all? { |role_name| has_role?(role_name) }
  end

  # Check if user has a specific permission
  def has_permission?(permission_name, resource = nil)
    # Use caching for performance
    cached_permissions = Rails.cache.fetch("user_#{id}_permissions", expires_in: 1.hour) do
      permissions.pluck(:name, :resource_type, :resource_id).map do |name, type, id|
        { name: name, resource_type: type, resource_id: id }
      end
    end

    if resource
      cached_permissions.any? do |perm|
        perm[:name] == permission_name &&
          perm[:resource_type] == resource.class.name &&
          perm[:resource_id] == resource.id
      end
    else
      cached_permissions.any? { |perm| perm[:name] == permission_name && perm[:resource_type].nil? }
    end
  end

  # Check if user has any of the given permissions
  def has_any_permission?(*permission_names)
    permission_names.any? { |perm| has_permission?(perm) }
  end

  # Check if user has all of the given permissions
  def has_all_permissions?(*permission_names)
    permission_names.all? { |perm| has_permission?(perm) }
  end

  # Get all permission names for the user
  def permission_names
    Rails.cache.fetch("user_#{id}_permission_names", expires_in: 1.hour) do
      permissions.pluck(:name).uniq
    end
  end

  # Get all role names for the user
  def role_names
    roles.pluck(:name).uniq
  end

  # Check if user is an admin (has admin or super_admin role)
  def admin?
    has_any_role?("admin", "super_admin")
  end

  # Check if user is a super admin
  def super_admin?
    has_role?("super_admin")
  end
end
