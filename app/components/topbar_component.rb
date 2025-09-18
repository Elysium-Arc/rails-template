# frozen_string_literal: true

class TopbarComponent < BaseComponent
  def initialize(current_user: nil)
    @current_user = current_user
  end

  def available_locales
    helpers.available_locales
  end
end
