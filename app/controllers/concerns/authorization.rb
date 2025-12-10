module Authorization
  extend ActiveSupport::Concern

  included do
    helper_method :current_user_has_role?
    helper_method :current_user_has_permission?
    helper_method :current_user_admin?
  end

  def authorize_with_role!(role_name, resource_type = nil, resource_id = nil)
    return if current_user&.has_role?(role_name, resource_type, resource_id)

    handle_authorization_failure
  end

  def authorize_with_permission!(permission_name, resource_type = nil, resource_id = nil)
    return if current_user&.has_permission?(permission_name, resource_type, resource_id)

    handle_authorization_failure
  end

  def authorize_with_any_permission!(permission_names, resource_type = nil, resource_id = nil)
    return if current_user&.has_any_permission?(permission_names, resource_type, resource_id)

    handle_authorization_failure
  end

  def authorize_with_all_permissions!(permission_names, resource_type = nil, resource_id = nil)
    return if current_user&.has_all_permissions?(permission_names, resource_type, resource_id)

    handle_authorization_failure
  end

  def authorize_admin!
    return if current_user&.admin?

    handle_authorization_failure
  end

  def current_user_has_role?(role_name, resource_type = nil, resource_id = nil)
    current_user&.has_role?(role_name, resource_type, resource_id) || false
  end

  def current_user_has_permission?(permission_name, resource_type = nil, resource_id = nil)
    current_user&.has_permission?(permission_name, resource_type, resource_id) || false
  end

  def current_user_admin?
    current_user&.admin? || false
  end

  private

  def handle_authorization_failure
    if request.format.html?
      flash[:error] = I18n.t('authorization.not_authorized', default: 'You are not authorized to perform this action')
      redirect_to root_path
    else
      render json: { error: I18n.t('authorization.not_authorized', default: 'You are not authorized to perform this action') }, status: :forbidden
    end
  end
end
