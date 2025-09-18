# frozen_string_literal: true

class DataTableComponent < BaseComponent
  attr_reader :filters, :columns, :data, :pagy, :sort_column, :sort_direction, :current_filters, :action_buttons, :title, :active_filter_keys, :selectable, :selected_ids, :row_actions, :disable_sorting, :scrollable, :table_frame_id, :empty_message,
  :dom_id, :record_id

  def initialize(
    title: nil,
    filters: [],
    columns:,
    data:,
    pagy: nil,
    sort_column: nil,
    sort_direction: "asc",
    current_filters: {},
    action_buttons: [],
    active_filter_keys: [],
    selectable: false,
    selected_ids: [],
    row_actions: [],
    disable_sorting: false,
    scrollable: false,
    table_frame_id: nil,
    empty_message: nil,
    dom_id: nil,
    record_id: nil,
    **options
  )
    @title = title
    @filters = filters
    @columns = columns
    @data = data
    @pagy = pagy
    @sort_column = sort_column
    @sort_direction = sort_direction
    @current_filters = current_filters || {}
    @action_buttons = action_buttons
    @active_filter_keys = active_filter_keys || []
    @selectable = selectable
    @selected_ids = Array(selected_ids)
    @row_actions = Array(row_actions)
    @disable_sorting = disable_sorting
    @scrollable = scrollable
    @table_frame_id = table_frame_id
    @empty_message = empty_message
    @dom_id = dom_id
    @record_id = record_id
    @options = options
  end

  def container_classes
    "space-y-6"
  end

  def title_classes
    "text-2xl font-bold text-base-content"
  end

  def has_filters?
    @filters.any?
  end

  def has_action_buttons?
    @action_buttons.any?
  end

  def action_button_classes(button)
    base_classes = "btn btn-outline"
    size_classes = button[:size] ? "btn-#{button[:size]}" : ""
    # Apple-like clean design: outlined buttons with no fill
    [ base_classes, size_classes ].compact.join(" ")
  end

  def has_multiple_action_buttons?
    @action_buttons.length > 1
  end

  def primary_action_button
    @action_buttons.first
  end

  def secondary_action_buttons
    @action_buttons[1..-1] || []
  end

  def filter_component
    @filter_component ||= FilterComponent.new(
      filters: @filters,
      current_filters: @current_filters,
      active_filter_keys: @active_filter_keys,
      sortable_columns: sortable_columns_list,
      current_sort: @sort_column,
      current_direction: @sort_direction,
      current_page: @pagy&.page,
      turbo_frame_id: @table_frame_id
    )
  end

  def sortable_columns_list
    @columns.select { |col| col[:sortable] != false }.map do |col|
      { key: col[:key], label: col[:label] }
    end
  end

  def pagy_component
    @pagy_component ||= PagyComponent.new(
      pagy: @pagy,
      form_id: filter_component.form_id
    )
  end
end
