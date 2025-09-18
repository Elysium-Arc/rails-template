# frozen_string_literal: true

class FlashComponent < BaseComponent
  attr_reader :flash, :position, :animation_duration, :default_timeout, :custom_templates

  def initialize(flash:, position: "top-right", animation_duration: 300, default_timeout: 6000, custom_templates: {})
    @flash = flash || {}
    @position = position
    @animation_duration = animation_duration
    @default_timeout = default_timeout
    @custom_templates = custom_templates
  end

  # Returns the CSS class for positioning
  def position_class
    rtl = I18n.locale.to_s == "ar"

    case position
    when "top-right"
      rtl ? "fixed top-20 left-4 z-50" : "fixed top-20 right-4 z-50"
    when "top-left"
      rtl ? "fixed top-20 right-4 z-50" : "fixed top-20 left-4 z-50"
    when "top-center"
      "fixed top-20 left-1/2 transform -translate-x-1/2 z-50"
    when "bottom-right"
      rtl ? "fixed bottom-4 left-4 z-50" : "fixed bottom-4 right-4 z-50"
    when "bottom-left"
      rtl ? "fixed bottom-4 right-4 z-50" : "fixed bottom-4 left-4 z-50"
    when "bottom-center"
      "fixed bottom-4 left-1/2 transform -translate-x-1/2 z-50"
    else position
    end
  end

  # Maps flash types to DaisyUI alert types
  def alert_type(type)
    case type.to_s
    when "alert", "error", "danger" then "error"
    when "notice", "success" then "success"
    when "warning", "warn" then "warning"
    when "info" then "info"
    else "info"
    end
  end

  # Returns timeout for a flash type, with fallbacks
  def timeout_for(type, message)
    # Check if message is a hash with timeout
    return message[:timeout] if message.is_a?(Hash) && message[:timeout]
    default_timeout
  end

  # Returns the actual message content
  def message_content(type, message)
    content = if message.is_a?(Hash)
      message[:message] || message[:content] || ""
    else
      message
    end

    # If content is a translation key (starts with "flash."), translate it
    if content.is_a?(String) && content.start_with?("flash.")
      I18n.t(content)
    else
      content
    end
  end

  # Returns custom classes for the flash item
  def custom_classes(type, message)
    if message.is_a?(Hash)
      message[:class] || ""
    else
      ""
    end
  end

  # Checks if a custom template exists for the type
  def custom_template?(type)
    custom_templates.key?(type.to_sym)
  end

  # Renders custom template if available
  def render_custom_template(type, message)
    template = custom_templates[type.to_sym]
    return unless template

    if template.respond_to?(:call)
      template.call(type, message)
    else
      template
    end
  end
end
