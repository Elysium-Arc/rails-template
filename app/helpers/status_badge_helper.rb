# frozen_string_literal: true

module StatusBadgeHelper
  # Render a status badge with consistent styling
  #
  # @param status [String, Symbol] The status value
  # @param variant [Symbol] The badge variant (:success, :error, :warning, :info, :primary, :secondary, :accent, :neutral, :ghost)
  # @param style [Symbol] The badge style (:default, :solid, :outlined)
  # @param size [Symbol] The badge size (:default, :sm, :lg)
  # @param pulse [Boolean] Whether to add pulse animation
  # @param dot [Boolean] Whether to add a dot indicator
  # @param translate [Boolean] Whether to translate the status text
  # @param translate_scope [String] The translation scope (e.g., 'common.status')
  # @param classes [String] Additional CSS classes
  # @return [String] HTML for the status badge
  def status_badge(status, variant: :neutral, style: :default, size: :default, pulse: false, dot: false, translate: true, translate_scope: "common.status", classes: "")
    return "" if status.blank?

    # Normalize status to string
    status_value = status.to_s

    # Build CSS classes
    badge_classes = build_badge_classes(variant, style, size, pulse, dot, classes)

    # Get display text
    display_text = if translate
      t("#{translate_scope}.#{status_value}", default: status_value.humanize)
    else
      status_value.humanize
    end

    content_tag(:span, display_text, class: badge_classes, title: display_text)
  end

  # Automatically determine badge variant based on status
  #
  # @param status [String, Symbol] The status value
  # @return [Hash] Options for status_badge method
  def auto_status_badge(status, **options)
    variant = case status.to_s.downcase
    when "active", "online", "connected", "success", "completed", "approved", "verified"
      :success
    when "inactive", "offline", "disconnected", "error", "failed", "rejected", "deleted"
      :error
    when "idle", "pending", "warning", "paused", "waiting"
      :warning
    when "info", "processing", "queued", "scheduled"
      :info
    else
      :neutral
    end

    status_badge(status, variant: variant, **options)
  end

  # Render an online/offline badge with pulse animation
  def online_status_badge(online, **options)
    if online
      status_badge("online", variant: :success, pulse: true, dot: true, **options)
    else
      status_badge("offline", variant: :error, **options)
    end
  end

  # Render a user activity status badge
  def user_status_badge(user, **options)
    auto_status_badge(user.status, **options)
  end

  # Render a terminal status badge
  def terminal_status_badge(terminal, **options)
    status = terminal.status
    variant = case status
    when "online" then :success
    when "offline" then :error
    else :warning
    end

    status_badge(status, variant: variant, pulse: status == "online", dot: status == "online", **options)
  end

  private

  def build_badge_classes(variant, style, size, pulse, dot, additional_classes)
    classes = [ "badge-status" ]

    # Base variant and style
    case style
    when :solid
      classes << "badge-status-#{variant}-solid"
    when :outlined
      classes << "badge-status-#{variant}-outlined"
    else
      classes << "badge-status-#{variant}"
    end

    # Size
    case size
    when :sm
      classes << "badge-status-sm"
    when :lg
      classes << "badge-status-lg"
    end

    # Modifiers
    classes << "badge-status-pulse" if pulse
    classes << "badge-status-with-dot" if dot && !pulse

    # Additional classes
    classes << additional_classes if additional_classes.present?

    classes.join(" ")
  end
end
