class User < ApplicationRecord
  audited
  include Hashid::Rails

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

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

  def has_role?(role_name, resource_type = nil, resource_id = nil)
    if resource_type.present?
      roles.exists?(
        name: role_name.to_s.strip.downcase,
        resource_type: resource_type,
        resource_id: resource_id
      )
    else
      roles.where(name: role_name.to_s.strip.downcase)
        .where(resource_type: nil, resource_id: nil)
        .exists?
    end
  end

  def has_permission?(permission_name, resource_type = nil, resource_id = nil)
    roles.joins(:permissions).exists?(
      permissions: {
        name: permission_name.to_s.strip.downcase,
        resource_type: resource_type,
        resource_id: resource_id
      }
    )
  end

  def grant_role(role)
    roles << role unless roles.include?(role)
  end

  def revoke_role(role)
    roles.delete(role)
  end

  def admin?
    has_role?('admin')
  end
end
