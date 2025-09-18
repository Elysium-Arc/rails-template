# frozen_string_literal: true

class LanguageDropdownComponent < BaseComponent
  def initialize(current_locale: nil)
    @current_locale = current_locale || I18n.locale
  end

  def available_locales
    helpers.available_locales
  end
end
