# frozen_string_literal: true

class SidebarComponent < BaseComponent
  attr_reader :current_user, :current_controller

  def initialize(current_user:, collapsed: false, current_controller: nil)
    @current_user = current_user
    @collapsed = collapsed
    @current_controller = current_controller
  end

  def links
    [
      { name: I18n.t("sidebar.links.dashboard"), path: root_path, icon: "home", controllers: [ "dashboard" ] },
      { name: I18n.t("sidebar.links.users"), path: users_path, icon: "users", controllers: [ "users" ]  }
    ]
  end

  def active_link?(link)
    controllers = Array(link[:controllers] || link[:controller])
    controllers.include?(@current_controller)
  end
end
