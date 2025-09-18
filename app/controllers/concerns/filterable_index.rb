# frozen_string_literal: true

module FilterableIndex
  extend ActiveSupport::Concern

  private

  def filterable_index(model_class, custom_filters: [], base_scope: nil, default_limit: 10, default_sort: nil, custom_params: params)
    # Build filters
    @filters = FilterBuilder.build_filters_for_model(model_class, custom_filters)

    # Build Ransack query from filter parameters using FilterBuilder
    query_params = FilterBuilder.build_query_params(@filters, custom_params)
    scope = base_scope || model_class.all
    @q = scope.ransack(query_params)
    records = @q.result

    # Apply sorting
    if custom_params["sort"].present?
      sort_columns = Array.wrap(custom_params["sort"])
      directions = Array.wrap(custom_params["direction"].presence || "asc")

      # Build ordering hash for multiple columns
      order_hash = {}
      sort_columns.each_with_index do |column, index|
        # Use the corresponding direction, or default to the last direction if fewer directions than columns
        dir = directions[index] || directions.last || "asc"
        order_hash[column] = (dir.to_s == "desc" ? :desc : :asc)
      end

      records = records.order(order_hash)
    elsif default_sort.present?
      records = records.order(default_sort)
    end

    # Apply pagination
    pagy_limit = (custom_params["limit"] || default_limit).to_i
    @pagy, paginated_records = pagy(records, limit: pagy_limit)

    # Determine which filters are active based on custom_params
    @active_filter_keys = FilterBuilder.determine_active_filter_keys(@filters, custom_params)

    paginated_records
  end
end
