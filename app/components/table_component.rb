# frozen_string_literal: true

class TableComponent < BaseComponent
  attr_reader :columns, :data, :pagy, :sort_column, :sort_direction, :empty_message, :table_id, :selectable, :selected_ids, :row_actions, :disable_sorting, :scrollable, :column_styles, :cell_styles, :dom_id, :record_id

  def initialize(
    columns:,
    data:,
    pagy: nil,
    sort_column: nil,
    sort_direction: "asc",
    empty_message: I18n.t("table.empty_message", default: "No records found"),
    table_id: nil,
    selectable: false,
    selected_ids: [],
    row_actions: [],
    disable_sorting: false,
    scrollable: false,
    column_styles: nil,
    cell_styles: nil,
    dom_id: nil,
    record_id: nil,
    **options
  )
    @columns = columns.map { |col| Column.new(col) }
    @data = data
    @pagy = pagy
    # Support both single and multiple sort columns
    @sort_column = Array.wrap(sort_column).compact
    @sort_direction = Array.wrap(sort_direction).compact
    # Ensure directions match sorts count
    @sort_direction = @sort_column.map.with_index { |_, i| @sort_direction[i] || @sort_direction.last || "asc" } if @sort_column.any?
    @empty_message = empty_message
    @table_id = table_id || "table-#{SecureRandom.hex(4)}"
    @selectable = selectable
    @selected_ids = Array(selected_ids)
    @row_actions = Array(row_actions)
    @disable_sorting = disable_sorting
    @scrollable = scrollable
    @column_styles = column_styles || {}
    @cell_styles = cell_styles || {}
    @options = options
  end

  def sortable?(column)
    return false if @disable_sorting
    column.sortable?
  end

  def sorted_by?(column, direction = nil)
    # Check if this column is in the sort array
    sort_index = @sort_column.index(column.key.to_s) || @sort_column.index(column.key)
    return false unless sort_index

    direction.nil? ? true : @sort_direction[sort_index] == direction
  end

  def sort_priority(column)
    # Return the sort priority (1-based index) or nil if not sorted
    sort_index = @sort_column.index(column.key.to_s) || @sort_column.index(column.key)
    sort_index ? sort_index + 1 : nil
  end

  def next_sort_direction(column)
    if sorted_by?(column, "asc")
      "desc"
    else
      "asc"
    end
  end

  def sort_icon(column)
    if sorted_by?(column)
      current_dir = @sort_direction[@sort_column.index(column.key.to_s) || @sort_column.index(column.key)]
      current_dir == "asc" ? "chevron-up" : "chevron-down"
    else
      "chevrons-up-down"
    end
  end

  def cell_value(record, column)
    value = column.value_from_record(record)

    # Handle nil values with default
    if value.nil? && column.default_value.present?
      return column.default_value
    end

    column.format_value(value)
  end

  def record_selected?(record)
    return false unless selectable
    @selected_ids.include?(record.id)
  end

  def record_id(record)
    if @record_id.respond_to?(:call)
      @record_id.call(record)
    elsif @record_id
      record.send(@record_id)
    else
      record.id
    end
  end

  def all_selected?
    return false unless selectable
    return false if @data.empty?
    @data.all? { |record| @selected_ids.include?(record.id) }
  end

  def has_row_actions?
    @row_actions.any?
  end

  def container_classes
    if @scrollable
      "overflow-x-auto max-w-full"
    else
      ""
    end
  end

  def responsive_classes
    "table w-full text-xs sm:text-sm border-collapse"
  end

  def header_classes(column)
    base_classes = "text-left font-medium border-b border-base-300 transition-all duration-200 focus:outline-none focus:ring-2 focus:ring-primary/20 focus:ring-offset-1"
    padding_classes = "px-2 py-2 sm:px-3 sm:py-2.5 md:px-4 md:py-3" # Responsive padding
    sortable_classes = sortable?(column) ? "hover:bg-base-200/50 cursor-pointer select-none" : ""
    sorted_classes = sorted_by?(column) ? "bg-primary/10 text-primary border-b-2 border-primary font-semibold" : "text-base-content/70"

    # Responsive visibility based on priority
    visibility_classes = if @scrollable
      ""
    elsif column.low_priority?
      "hidden lg:table-cell" # Hide on mobile/tablet, show on desktop
    elsif column.high_priority?
      "table-cell" # Always visible
    else
      "hidden md:table-cell" # Hide on mobile, show on tablet+
    end

    default_classes = [ base_classes, padding_classes, sortable_classes, sorted_classes, visibility_classes ].compact.join(" ")

    # Apply custom column styles if provided (component-level)
    default_classes = apply_custom_styles(default_classes, column, :column_styles)

    # Apply column-specific header classes if provided (column-level)
    if column.header_class.present?
      default_classes = merge_or_replace_classes(default_classes, column.header_class, column.header_class_mode)
    end

    default_classes
  end

  def cell_classes(column)
    base_classes = "border-b border-base-200/50 text-base-content hover:bg-base-50/50 transition-colors duration-150"
    padding_classes = "px-2 py-2 sm:px-3 sm:py-2.5 md:px-4 md:py-3" # Responsive padding

    # Responsive visibility based on priority
    visibility_classes = if @scrollable
      ""
    elsif column.low_priority?
      "hidden lg:table-cell"
    elsif column.high_priority?
      "table-cell"
    else
      "hidden md:table-cell"
    end

    # Text truncation if specified
    truncate_classes = column.should_truncate? ? "max-w-xs truncate" : ""

    default_classes = [ base_classes, padding_classes, visibility_classes, truncate_classes ].compact.join(" ")

    # Apply custom cell styles if provided (component-level)
    default_classes = apply_custom_styles(default_classes, column, :cell_styles)

    # Apply column-specific cell classes if provided (column-level, non-Proc)
    if column.cell_class.present? && !column.cell_class.is_a?(Proc)
      default_classes = merge_or_replace_classes(default_classes, column.cell_class, column.cell_class_mode)
    end

    default_classes
  end

  def cell_classes_for_record(column, record)
    classes = cell_classes(column)

    # Apply dynamic cell styles based on record if provided (Proc only)
    if column.cell_class.is_a?(Proc)
      dynamic_classes = column.cell_class.call(record)
      classes = merge_or_replace_classes(classes, dynamic_classes, column.cell_class_mode)
    end

    classes
  end

  def empty_row_classes
    "px-4 py-8 text-center"
  end

  private

  # Apply custom styles to default classes
  # Supports both shared styles (for all columns) and column-specific styles
  def apply_custom_styles(default_classes, column, style_type)
    styles = instance_variable_get("@#{style_type}")
    return default_classes if styles.blank?

    # Check for shared styles (applied to all columns)
    if styles[:shared]
      default_classes = merge_or_replace_classes(default_classes, styles[:shared][:classes], styles[:shared][:mode])
    end

    # Check for column-specific styles
    column_key = column.key.to_sym
    if styles[column_key]
      default_classes = merge_or_replace_classes(default_classes, styles[column_key][:classes], styles[column_key][:mode])
    end

    default_classes
  end

  # Merge or replace classes based on mode
  # mode: :add (default) - adds to existing classes
  # mode: :replace - replaces existing classes entirely
  def merge_or_replace_classes(default_classes, custom_classes, mode = :add)
    return default_classes if custom_classes.blank?

    case mode&.to_sym
    when :replace
      custom_classes
    else # :add or nil (default)
      "#{default_classes} #{custom_classes}".strip
    end
  end

  public

  class Column
    attr_reader :key, :label, :sortable, :type, :formatter, :value_method, :priority, :truncate, :default_value, :format, :header_class, :header_class_mode, :cell_class, :cell_class_mode

    def initialize(options = {})
      @key = options[:key] || options[:attribute]
      @label = options[:label] || @key.to_s.humanize
      @sortable = options.fetch(:sortable, true)
      @type = options[:type] || :string
      @formatter = options[:formatter]
      @format = options[:format] # For custom lambda formatters
      @value_method = options[:value_method] || @key
      @priority = options[:priority] || :normal # :high, :normal, :low
      @truncate = options.fetch(:truncate, false)
      @default_value = options[:default_value] # Default value for nil

      # Custom styling options
      @header_class = options[:header_class] # String or Proc for custom header classes
      @header_class_mode = options[:header_class_mode] || :add # :add or :replace
      @cell_class = options[:cell_class] # String or Proc for custom cell classes
      @cell_class_mode = options[:cell_class_mode] || :add # :add or :replace
    end

    def sortable?
      @sortable
    end

    def high_priority?
      @priority == :high
    end

    def low_priority?
      @priority == :low
    end

    def should_truncate?
      @truncate
    end

    def value_from_record(record)
      # Use custom format lambda if provided
      if @format.is_a?(Proc)
        return @format.call(record)
      end

      if @value_method.is_a?(Proc)
        @value_method.call(record)
      elsif record.respond_to?(@value_method)
        record.send(@value_method)
      elsif record.is_a?(Hash)
        record[@value_method] || record[@value_method.to_s]
      else
        record
      end
    end

    def format_value(value)
      return "" if value.nil?

      if @formatter.is_a?(Proc)
        @formatter.call(value)
      elsif @formatter.is_a?(Symbol)
        send(@formatter, value)
      else
        case @type
        when :currency
          format_currency(value)
        when :date
          format_date(value)
        when :datetime
          format_datetime(value)
        when :boolean
          format_boolean(value)
        else
          value.to_s
        end
      end
    end

    private

    def format_currency(value)
      ActionController::Base.helpers.number_to_currency(value)
    end

    def format_date(value)
      value.strftime("%Y-%m-%d")
    end

    def format_datetime(value)
      value.strftime("%Y-%m-%d %H:%M")
    end

    def format_boolean(value)
      value ? "Yes" : "No"
    end
  end
end
