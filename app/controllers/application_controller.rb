class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  include Pagy::Backend
  include Pagy::Frontend
  FILTER_SESSION_KEY = :_active_filters
  FILTER_TTL = 30.minutes

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  layout "authenticated"

  before_action :set_locale
  helper_method :current_user

  def current_user
    Current.user
  end

  def turbo_frame_request?
    request.headers["Turbo-Frame"].present?
  end

  def redirect_if_html_request
    respond_to do |format|
      format.html { redirect_to root_path }
    end
  end

  def close_modal
    turbo_stream.dispatch_event("#app-modal", "modal:close")
  end

  # Helper to generate a Turbo Stream flash message
  # @param type [Symbol, String] The flash type (:success, :error, :warning, :info, :notice)
  # @param message [String] The message text or translation key
  # @param translate [Boolean] Whether to translate the message (default: true)
  # @param default [String, nil] Default message if translation fails
  # @return [Turbo::Streams::TagBuilder] A turbo stream that prepends a flash message
  def turbo_flash(type, message, translate: true, default: nil)
    translated_message = if translate && message.is_a?(String)
      t(message, default: default || message)
    else
      message
    end

    turbo_stream.prepend("flash-messages", partial: "shared/flash_item", locals: {
      type: type,
      message: translated_message
    })
  end

  private

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  # def default_url_options
  #   { locale: I18n.locale }
  # end

  def persist_filters
    f = session[FILTER_SESSION_KEY]

    # restore if valid and same controller
    if f && f["controller"] == controller_name && f["stored_at"] > FILTER_TTL.ago && request.get? && params.to_unsafe_h.except(:controller, :action).empty?
      query = Rack::Utils.parse_nested_query(URI(f["query"]).query)
      params.merge!(query)
    end

    # store if new GET request with query
    if request.get? && request.query_string.present?
      session[FILTER_SESSION_KEY] = {
        controller: controller_name,
        query: request.fullpath,
        stored_at: Time.current
      }
    end
  end

  def current_filters
    f = session[FILTER_SESSION_KEY]
    return {} unless f && f["controller"] == controller_name && f["stored_at"] > FILTER_TTL.ago
    Rack::Utils.parse_nested_query(URI(f["query"]).query)
  end
end
