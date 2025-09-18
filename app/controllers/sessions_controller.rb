class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[new create]
  before_action :redirect_if_authenticated, only: %i[new create]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_session_url, alert: "flash.rate_limited" }

  layout "application", only: %i[new create]

  def new
    @url = login_path
  end

  def create
    result = User.authenticate_by(permitted_params)

    case result
    when User
      start_new_session_for result
      redirect_to after_authentication_url, notice: "flash.sessions.login_success"
    when :user_not_found, :invalid_password
      alert_key = "sessions.new.errors.#{result}"
      redirect_to login_path, alert: I18n.t(alert_key)
    else
      # Fallback to the generic message for unexpected cases
      redirect_to login_path, alert: I18n.t("sessions.new.error")
    end
  end

  def destroy
    terminate_session
    redirect_to login_path, notice: "flash.sessions.logout_success"
  end

  private

  def permitted_params
    params.require(:session).permit(:email_address, :password)
  end

  def redirect_if_authenticated
    redirect_to root_path(locale) if authenticated?
  end
end
