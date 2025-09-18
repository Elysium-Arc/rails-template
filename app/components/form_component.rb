# frozen_string_literal: true

class FormComponent < BaseComponent
  attr_reader :model, :url, :method, :fields, :sections, :submit_label, :cancel_url, :form_options

  def initialize(
    model:,
    url:,
    method: :post,
    fields: [],
    sections: [],
    submit_label: nil,
    submit_icon: nil,
    submit_button_class: nil,
    cancel_url: nil,
    show_cancel: true,
    html_options: {},
    **options
  )
    @model = model
    @url = url
    @method = method
    @fields = fields
    @sections = sections
    @submit_label = submit_label
    @submit_icon = submit_icon
    @submit_button_class = submit_button_class
    @cancel_url = cancel_url
    @show_cancel = show_cancel
    @html_options = html_options
    @options = options
  end

  def form_id
    model_name = model_name_string
    @model.persisted? ? "edit_#{model_name}_#{@model.id}" : "new_#{model_name}"
  end

  def model_name_string
    @model.class.name.underscore
  end

  def model_i18n_key
    @model.class.model_name.i18n_key
  end

  def default_submit_label
    action = @model.persisted? ? "update" : "create"
    I18n.t("helpers.submit.#{action}", model: @model.class.model_name.human, default: action.capitalize)
  end

  def submit_text
    @submit_label || default_submit_label
  end

  def submit_icon
    @submit_icon
  end

  def show_cancel?
    @show_cancel
  end

  def has_sections?
    @sections.any?
  end

  def has_fields?
    @fields.any?
  end

  def form_html_options
    default_options = {
      id: form_id,
      class: "space-y-6"
    }
    default_options.merge(@html_options)
  end

  # CSS Classes
  def input_classes(field = {})
    base = "form-input"
    extra = field[:input_html]&.dig(:class) || ""
    "#{base} #{extra}".strip
  end

  def select_classes(field = {})
    base = "form-select"
    extra = field[:input_html]&.dig(:class) || ""
    "#{base} #{extra}".strip
  end

  def textarea_classes(field = {})
    base = "form-textarea"
    extra = field[:input_html]&.dig(:class) || ""
    "#{base} #{extra}".strip
  end

  def checkbox_classes(field = {})
    base = "form-checkbox"
    extra = field[:input_html]&.dig(:class) || ""
    "#{base} #{extra}".strip
  end

  def label_classes
    "form-label"
  end

  def error_classes
    "form-error"
  end

  def form_section_classes
    "space-y-4"
  end

  def button_group_classes
    base = "flex items-center justify-end gap-3"
    # Only add border/padding if there are multiple buttons or cancel is shown
    if show_cancel?
      "#{base} mt-8 pt-4 border-t border-base-300"
    else
      "#{base} mt-6"
    end
  end

  def submit_button_classes
    @submit_button_class || "btn-submit min-w-[120px]"
  end

  def cancel_button_classes
    "btn-cancel"
  end

  # Field helpers
  def field_label(form, field)
    return nil if field[:as] == :hidden

    label_text = field[:label]
    if label_text.nil?
      # Use i18n for automatic label translation
      label_text = I18n.t(
        "activerecord.attributes.#{model_i18n_key}.#{field[:name]}",
        default: field[:name].to_s.humanize
      )
    end

    return nil if label_text == false

    required = field[:required] || false
    required_mark = required ? content_tag(:span, "*", class: "text-error ml-1") : ""

    content_tag(:span, class: label_classes) do
      label_text.html_safe + required_mark
    end
  end

  def field_errors(field)
    return unless @model.errors[field[:name]].any?

    content_tag(:label, class: "label") do
      content_tag(:span, @model.errors[field[:name]].first, class: error_classes)
    end
  end

  def field_hint(field)
    return unless field[:hint]

    content_tag(:label, class: "label") do
      content_tag(:span, field[:hint], class: "form-hint")
    end
  end

  def field_wrapper_classes(field)
    base = "form-control"

    # Add width classes if specified
    if field[:wrapper_html] && field[:wrapper_html][:class]
      base = "#{base} #{field[:wrapper_html][:class]}"
    end

    base
  end

  def field_input_html_options(field)
    options = field[:input_html]&.dup || {}

    # Remove class as it's handled separately
    options.delete(:class)

    # Add placeholder if not present
    unless options[:placeholder] || field[:as] == :hidden
      placeholder = I18n.t(
        "activerecord.attributes.#{model_i18n_key}.#{field[:name]}",
        default: field[:name].to_s.humanize
      )
      options[:placeholder] = field[:placeholder] || placeholder
    end

    # Add min/max attributes for number, date, datetime, time fields
    options[:min] = field[:min] if field[:min].present?
    options[:max] = field[:max] if field[:max].present?

    # Add minlength/maxlength for text fields
    options[:minlength] = field[:minlength] if field[:minlength].present?
    options[:maxlength] = field[:maxlength] if field[:maxlength].present?

    # Add step attribute for number/date/time fields
    options[:step] = field[:step] if field[:step].present?

    # Add pattern for validation
    options[:pattern] = field[:pattern] if field[:pattern].present?

    # Add autocomplete if not present
    options[:autocomplete] ||= "off" if [ :password ].include?(field[:as])

    # Add autofocus if specified
    options[:autofocus] = true if field[:autofocus]

    # Add required if specified
    options[:required] = true if field[:required]

    # Add readonly if specified
    options[:readonly] = true if field[:readonly]

    # Add disabled if specified
    options[:disabled] = true if field[:disabled]

    # Merge any additional custom options
    options.merge!(field[:options]) if field[:options].is_a?(Hash)

    options
  end

  def render_field_input(form, field)
    # If custom_html is provided as a Proc, use it directly
    if field[:custom_html].is_a?(Proc)
      return field[:custom_html].call(form, field, self)
    end

    # If custom_html is provided as a string, render it directly
    if field[:custom_html].is_a?(String)
      return field[:custom_html].html_safe
    end

    case field[:as]
    when :hidden
      form.hidden_field(field[:name], field_input_html_options(field))
    when :text, :string, nil
      form.text_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :email
      form.email_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :password
      form.password_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :number, :integer
      form.number_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :tel, :phone
      form.telephone_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :url
      form.url_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :date
      form.date_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :datetime
      form.datetime_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :time
      form.time_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    when :textarea, :text_area
      rows = field[:rows] || 4
      form.text_area(
        field[:name],
        field_input_html_options(field).merge(class: textarea_classes(field), rows: rows)
      )
    when :select
      choices = field[:collection] || []
      include_blank = field[:include_blank]
      include_blank_text = if include_blank.is_a?(String)
        include_blank
      elsif include_blank
        I18n.t("common.select", default: "Select...")
      else
        false
      end

      form.select(
        field[:name],
        choices,
        { include_blank: include_blank_text },
        field_input_html_options(field).merge(class: select_classes(field))
      )
    when :checkbox, :boolean
      label_tag = content_tag(:label, class: "form-checkbox-label") do
        checkbox = form.check_box(
          field[:name],
          field_input_html_options(field).merge(class: checkbox_classes(field))
        )
        label_text = field[:label] || I18n.t(
          "activerecord.attributes.#{model_i18n_key}.#{field[:name]}",
          default: field[:name].to_s.humanize
        )
        checkbox + content_tag(:span, label_text, class: "label-text font-medium")
      end
      label_tag
    when :radio_buttons
      collection = field[:collection] || []
      content_tag(:div, class: "space-y-2") do
        collection.map do |item|
          value = item.is_a?(Array) ? item.last : item
          label = item.is_a?(Array) ? item.first : item.to_s.humanize

          content_tag(:label, class: "form-radio-label") do
            radio = form.radio_button(
              field[:name],
              value,
              field_input_html_options(field).merge(class: "radio radio-accent")
            )
            radio + content_tag(:span, label, class: "label-text")
          end
        end.join.html_safe
      end
    when :file
      form.file_field(
        field[:name],
        field_input_html_options(field).merge(class: "form-file")
      )
    when :range
      form.range_field(
        field[:name],
        field_input_html_options(field).merge(class: "range range-accent")
      )
    when :color
      form.color_field(
        field[:name],
        field_input_html_options(field).merge(class: "input input-bordered")
      )
    when :search
      form.search_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    else
      # Default to text field
      form.text_field(
        field[:name],
        field_input_html_options(field).merge(class: input_classes(field))
      )
    end
  end

  def render_field(form, field)
    # For checkbox/boolean, the label is part of the input rendering
    if field[:as] == :checkbox || field[:as] == :boolean
      content_tag(:div, class: field_wrapper_classes(field)) do
        render_field_input(form, field) +
        content_tag(:div, class: "flex flex-col gap-1") do
          (field_errors(field) || "".html_safe) +
          (field_hint(field) || "".html_safe)
        end
      end
    else
      content_tag(:div, class: field_wrapper_classes(field)) do
        (field_label(form, field) || "".html_safe) +
        render_field_input(form, field) +
        content_tag(:div, class: "flex flex-col gap-1") do
          (field_errors(field) || "".html_safe) +
          (field_hint(field) || "".html_safe)
        end
      end
    end
  end

  def render_section(form, section)
    content_tag(:div, class: "space-y-4") do
      section_header = if section[:title]
        content_tag(:h3, section[:title], class: "text-lg font-semibold text-base-content mb-4")
      else
        "".html_safe
      end

      section_description = if section[:description]
        content_tag(:p, section[:description], class: "text-sm text-base-content/60 mb-4")
      else
        "".html_safe
      end

      fields_html = if section[:columns]
        # Grid layout
        content_tag(:div, class: "grid grid-cols-1 md:grid-cols-#{section[:columns]} gap-4") do
          section[:fields].map { |field| render_field(form, field) }.join.html_safe
        end
      else
        # Stack layout
        content_tag(:div, class: "space-y-4") do
          section[:fields].map { |field| render_field(form, field) }.join.html_safe
        end
      end

      section_header + section_description + fields_html
    end
  end
end
