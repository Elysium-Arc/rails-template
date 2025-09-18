# frozen_string_literal: true

class FilterComponent < BaseComponent
  attr_reader :filters, :current_filters, :form_id, :active_filter_keys, :sortable_columns, :current_sort, :current_direction, :current_page

  def initialize(
    filters:,
    current_filters: {},
    form_id: nil,
    active_filter_keys: [],
    sortable_columns: [],
    current_sort: nil,
    current_direction: nil,
    current_page: nil,
    **options
  )
    @filters = filters.map { |filter| Filter.new(filter) }
    @current_filters = current_filters || {}
    @form_id = form_id || "filter-form-#{SecureRandom.hex(4)}"
    @active_filter_keys = active_filter_keys || []
    @sortable_columns = sortable_columns || []
    # Support both single and multiple sort columns
    @current_sort = Array.wrap(current_sort).compact
    @current_direction = Array.wrap(current_direction).compact
    # Ensure directions match sorts count
    @current_direction = @current_sort.map.with_index { |_, i| @current_direction[i] || @current_direction.last || "asc" } if @current_sort.any?
    @current_page = current_page
    @options = options
  end

  def form_classes
    # Stack filters vertically and provide spacing
    "flex flex-col p-4 bg-base-100 rounded-box shadow-xs border border-base-200"
  end

  def filter_container_classes
    # Each filter takes its own row
    "flex flex-col gap-2 min-w-0 w-full sm:w-fit"
  end

  def label_classes
    "text-sm font-medium text-base-content/70"
  end

  def input_classes(filter)
    base_classes = "input input-bordered w-full"

    case filter.type
    when :select
      "#{base_classes} select"
    when :date, :datetime
      "#{base_classes} input-bordered"
    else
      base_classes
    end
  end

  def button_container_classes
    "flex items-center gap-2"
  end

  def submit_button_classes
    "btn btn-primary"
  end

  def clear_button_classes
    "btn btn-ghost"
  end

  def current_value(filter)
    # Handle range-like filters (they store gteq/lteq params)
    if filter.multiple_inputs?
      left = @current_filters["#{filter.ransack_key}_gteq"] || @current_filters["#{filter.ransack_key}_gteq".to_s]
      right = @current_filters["#{filter.ransack_key}_lteq"] || @current_filters["#{filter.ransack_key}_lteq".to_s]

      # If both ends are blank/nil, treat the filter as absent so it doesn't render by default
      if left.to_s.strip.empty? && right.to_s.strip.empty?
        return nil
      end

      [ left.presence, right.presence ]
    end

    @current_filters[filter.key] || @current_filters[filter.key.to_s]
  end

  def current_operator(filter)
    @current_filters["#{filter.key}_operator"] || filter.default_operator
  end

  def active_filters
    if @active_filter_keys.any?
      @filters.select { |filter| @active_filter_keys.include?(filter.key) }
    else
      @filters.select { |filter| current_value(filter).present? }
    end
  end

  def available_filters
    @filters.reject { |filter| active_filter_keys.include?(filter.key) }
  end

  def has_sortable_columns?
    @sortable_columns.any?
  end

  def sort_options
    @sortable_columns.map do |col|
      label = col[:label] || col[:key].to_s.humanize
      [ label, col[:key].to_s ]
    end
  end

  def current_sort_label
    return nil unless @current_sort.present? && @current_sort.any?

    col = @sortable_columns.find { |c| c[:key].to_s == @current_sort.first.to_s }
    col ? (col[:label] || col[:key].to_s.humanize) : @current_sort.first.to_s.humanize
  end

  # Returns array of active sort criteria as hashes with column info
  def active_sorts
    @current_sort.map.with_index do |sort_col, index|
      col = @sortable_columns.find { |c| c[:key].to_s == sort_col.to_s }
      {
        key: sort_col,
        label: col ? (col[:label] || col[:key].to_s.humanize) : sort_col.to_s.humanize,
        direction: @current_direction[index] || "asc",
        index: index
      }
    end
  end

  def has_active_sorts?
    @current_sort.any?
  end

  # Check if a specific column is currently being sorted
  def column_sorted?(column_key)
    @current_sort.include?(column_key.to_s)
  end

  # Get the direction for a specific sorted column
  def column_sort_direction(column_key)
    index = @current_sort.index(column_key.to_s)
    index ? @current_direction[index] : nil
  end

  def display_filter_value(filter)
    value = current_value(filter)
    return "" unless value.present?

    case filter.type
    when :date
      Date.parse(value).strftime("%b %d, %Y") rescue value
    when :datetime
      DateTime.parse(value).strftime("%b %d, %Y %H:%M") rescue value
    when :date_range, :datetime_range, :number_range
      # value is expected to be an array [from, to]
      from, to = Array(value)
      parts = []
      parts << (from.presence || "")
      parts << (to.presence || "")
      parts.reject(&:blank?).join(" — ")
    when :select
      filter.select_options.find { |opt| opt.is_a?(Array) ? opt[1] == value : opt == value }&.first || value
    else
      value.length > 20 ? "#{value[0..17]}..." : value
    end
  end

  def filter_name(filter)
    case filter.type
    when :date_range, :number_range, :datetime_range
      [ "#{filter.ransack_key}_gteq", "#{filter.ransack_key}_lteq" ]
    else
      filter.ransack_key
    end
  end

  class Filter
    attr_reader :key, :label, :type, :options, :placeholder, :required, :association, :attribute_name, :model

    def initialize(options = {})
      # Handle both hash options and existing Filter instances
      if options.is_a?(Filter)
        # Copy attributes from existing Filter
        @key = options.key.to_sym
        @label = options.label
        @type = options.type
        @options = options.options
        @placeholder = options.placeholder
        @required = options.required
        @association = options.association
        @attribute_name = options.attribute_name
        @model = options.model
      else
        # Normal initialization from hash
        @key = (options[:key] || options[:attribute] || "id").to_sym
        @label = options[:label] || @key.to_s.humanize
        @type = options[:type] || :text
        @options = options[:options] || []
        @placeholder = options[:placeholder] || label.downcase
        @required = options.fetch(:required, false)
        @association = options[:association]
        @attribute_name = options[:attribute_name] || @key
        @model = options[:model]
      end
    end

    def select_options
      return @options if @options.is_a?(Array)

      if @options.is_a?(Proc)
        @options.call
      elsif @association && @model
        # Auto-generate options for associations
        associated_model = @model.reflect_on_association(@association)&.klass
        if associated_model
          associated_model.all.map { |record| [ record.send(@attribute_name || :name).to_s, record.id ] }
        else
          []
        end
      else
        []
      end
    end

    def input_type
      case @type
      when :email
        # Use a plain text input for email in filters to avoid browser autofill UI
        "text"
      when :number, :number_range
        "number"
      when :date
        "date"
      when :date_range
        "date"
      when :datetime_range
        "datetime-local"
      when :datetime
        "datetime-local"
      when :boolean
        "checkbox"
      else
        "text"
      end
    end

    def multiple_inputs?
      [ :date_range, :number_range, :datetime_range ].include?(@type)
    end

    def operators
      case @type
      when :text, :string, :email
        [
          { value: "cont", label: I18n.t("filters.operators.cont", default: "Contains") },
          { value: "eq", label: I18n.t("filters.operators.eq", default: "Equals") },
          { value: "start", label: I18n.t("filters.operators.start", default: "Starts with") },
          { value: "end", label: I18n.t("filters.operators.end", default: "Ends with") },
          { value: "not_cont", label: I18n.t("filters.operators.not_cont", default: "Does not contain") }
        ]
      when :number
        [
          { value: "eq", label: I18n.t("filters.operators.eq", default: "Equals") },
          { value: "gt", label: I18n.t("filters.operators.gt", default: "Greater than") },
          { value: "gteq", label: I18n.t("filters.operators.gteq", default: "Greater than or equal") },
          { value: "lt", label: I18n.t("filters.operators.lt", default: "Less than") },
          { value: "lteq", label: I18n.t("filters.operators.lteq", default: "Less than or equal") },
          { value: "not_eq", label: I18n.t("filters.operators.not_eq", default: "Not equal") }
        ]
      when :date, :datetime, :datetime_range, :date_range
        [
          { value: "eq", label: I18n.t("filters.operators.eq", default: "Equals") },
          { value: "gt", label: I18n.t("filters.operators.gt", default: "After") },
          { value: "gteq", label: I18n.t("filters.operators.gteq", default: "On or after") },
          { value: "lt", label: I18n.t("filters.operators.lt", default: "Before") },
          { value: "lteq", label: I18n.t("filters.operators.lteq", default: "On or before") }
        ]
      when :boolean
        [
          { value: "true", label: I18n.t("filters.operators.yes", default: "Yes") },
          { value: "false", label: I18n.t("filters.operators.no", default: "No") }
        ]
      when :select
        [
          { value: "eq", label: I18n.t("filters.operators.eq", default: "Equals") },
          { value: "not_eq", label: I18n.t("filters.operators.not_eq", default: "Not equal") }
        ]
      else
  [ { value: "cont", label: I18n.t("filters.operators.cont", default: "Contains") } ]
      end
    end

    def default_operator
      operators.first[:value]
    end

    def ransack_key(operator = nil)
      base_key = @association ? "#{@association}_#{@attribute_name}" : @attribute_name
      suffix = operator || default_operator

      case @type
      when :date_range, :number_range, :datetime_range
        base_key
      else
        "#{base_key}_#{suffix}"
      end
    end
  end
end
