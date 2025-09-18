module ApplicationHelper
  include StatusBadgeHelper

  # Returns the available locales for the language switcher
  def available_locales
    [
      { code: :en, label: "English", icon: "us", library: "flags" },
      { code: :fr, label: "Français", icon: "fr", library: "flags" },
      { code: :ar, label: "العربية", icon: "ma", library: "flags" }
    ]
  end

  # Render table cell value based on column configuration
  # Used for individual row replacements in Turbo Stream responses
  def render_table_cell_value(record, column)
    value = record.send(column[:key])

    # Use format proc if provided
    if column[:format].is_a?(Proc)
      return column[:format].call(record)
    end

    # Handle different data types
    case column[:type]
    when :datetime
      value ? l(value, format: :short) : (column[:default_value] || "-")
    when :date
      value ? l(value, format: :short) : (column[:default_value] || "-")
    when :boolean
      value ? content_tag(:span, "✓", class: "text-success") : content_tag(:span, "✗", class: "text-error")
    else
      if value.nil? || (value.is_a?(String) && value.blank?)
        column[:default_value] || "-"
      elsif column[:truncate]
        content_tag(:div, value, class: "truncate max-w-xs", title: value)
      else
        value
      end
    end
  end
end
