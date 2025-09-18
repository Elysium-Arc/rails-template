# frozen_string_literal: true

class FilterBuilder
  def self.build_filters_for_model(model_class, custom_filters = [])
    cache_key = [
      "filter_builder",
      model_class.name,
      model_class.columns_hash.keys.hash,
      model_class.reflect_on_all_associations.map(&:name).hash,
      custom_filters.hash
    ].join("/")

    Rails.cache.fetch(cache_key, expires_in: 12.hours) do
      filters = []

      custom_filters.each do |filter_config|
        filters << build_filter_from_config(filter_config, model_class)
      end

      custom_keys = custom_filters.map { |f| f[:attribute] || f[:key] }

      model_class.columns.each do |column|
        next if custom_keys.include?(column.name.to_sym)
        next if %w[id created_at updated_at password_digest encrypted_password].include?(column.name)
        filter = build_filter_from_column(column, model_class)
        filters << filter if filter
      end

      model_class.reflect_on_all_associations.each do |association|
        next if custom_keys.include?(association.name)
        filter = build_filter_from_association(association, model_class)
        filters << filter if filter
      end

      filters
    end
  end

  def self.build_filter_from_config(config, model_class)
    # Inject label resolved from i18n or fallbacks when available
    config = config.dup
    config[:model] = model_class
    config[:label] ||= label_for(model_class, config[:attribute] || config[:key])
    FilterComponent::Filter.new(config)
  end

  def self.build_filter_from_column(column, model_class)
    return nil if %w[id created_at updated_at].include?(column.name)

    case column.type
    when :string, :text
      if column.name.include?("email")
        FilterComponent::Filter.new(
          attribute: column.name,
          type: :email,
          model: model_class,
          label: label_for(model_class, column.name)
        )
      else
        FilterComponent::Filter.new(
          attribute: column.name,
          type: :text,
          model: model_class,
          label: label_for(model_class, column.name)
        )
      end
    when :integer, :float, :decimal
      FilterComponent::Filter.new(
        attribute: column.name,
        type: :number,
        model: model_class,
        label: label_for(model_class, column.name)
      )
    when :boolean
      FilterComponent::Filter.new(
        attribute: column.name,
        type: :boolean,
        model: model_class,
        label: label_for(model_class, column.name)
      )
    when :date
      FilterComponent::Filter.new(
        attribute: column.name,
        type: :date,
        model: model_class,
        label: label_for(model_class, column.name)
      )
    when :datetime
      FilterComponent::Filter.new(
        attribute: column.name,
        type: :datetime,
        model: model_class,
        label: label_for(model_class, column.name)
      )
    else
      nil
    end
  end

  def self.build_filter_from_association(association, model_class)
    case association.macro
    when :belongs_to
      # Use association name label from the parent model if available
      FilterComponent::Filter.new(
        association: association.name,
        attribute_name: :name,
        type: :select,
        model: model_class,
        label: label_for(model_class, association.name)
      )
    else
      nil
    end
  end

  # Determine which filters are active based on incoming params
  def self.determine_active_filter_keys(filters, params)
    active_keys = []
    filters.each do |filter|
      filter_key = filter.key.to_s
      # Consider a filter active only if it has a real value in params.
      # For multi-input filters (ranges) check the ransack gteq/lteq params.
      if filter.multiple_inputs?
        from_key = "#{filter.ransack_key}_gteq"
        to_key = "#{filter.ransack_key}_lteq"
        if params[from_key].present? || params[to_key].present?
          active_keys << filter.key.to_sym
        end
      else
        if params[filter_key].present?
          active_keys << filter.key.to_sym
        end
      end
    end

    active_keys.uniq
  end

  # Build Ransack-friendly query params from an array of FilterComponent::Filter instances
  def self.build_query_params(filters, params)
    query = {}

    filters.each do |filter|
      filter_key = filter.key.to_s
      operator_key = "#{filter_key}_operator"
      value_key = filter_key
      if filter.multiple_inputs?
        # Expect params like key_gteq and key_lteq
        from_key = "#{filter.ransack_key}_gteq"
        to_key = "#{filter.ransack_key}_lteq"
        from = params[from_key].presence
        to = params[to_key].presence

        if from.present? || to.present?
          # Build both ends when present
          if from.present?
            ransack_key = "#{filter.ransack_key}_gteq"
            if [ :date, :date_range ].include?(filter.type)
              query[ransack_key] = Date.parse(from) rescue nil
            elsif [ :datetime, :datetime_range ].include?(filter.type)
              query[ransack_key] = DateTime.parse(from) rescue nil
            else
              query[ransack_key] = from
            end
          end

          if to.present?
            ransack_key = "#{filter.ransack_key}_lteq"
            if [ :date, :date_range ].include?(filter.type)
              query[ransack_key] = Date.parse(to) rescue nil
            elsif [ :datetime, :datetime_range ].include?(filter.type)
              query[ransack_key] = DateTime.parse(to) rescue nil
            else
              query[ransack_key] = to
            end
          end
        end
      else
        if params[value_key].present?
          operator = params[operator_key] || filter.default_operator
          value = params[value_key]

          ransack_key = filter.ransack_key(operator)

          case filter.type
          when :boolean
            query[ransack_key] = value == "true"
          when :date
            query[ransack_key] = Date.parse(value) rescue nil
          when :datetime
            query[ransack_key] = DateTime.parse(value) rescue nil
          else
            query[ransack_key] = value
          end
        end
      end
    end

    query
  end

  # Resolve a label for a model attribute or association using i18n fallbacks
  def self.label_for(model_class, attribute_or_assoc, attribute_name = nil)
    model_key = model_class.model_name.i18n_key
    attr = attribute_or_assoc.to_s

    # Try activerecord.attributes.{model}.{attribute}
    i18n_attr_key = "activerecord.attributes.#{model_key}.#{attr}"
    label = I18n.exists?(i18n_attr_key) ? I18n.t(i18n_attr_key) : nil

    return label if label.present?

    # If an explicit attribute_name is provided (for association labeling), try that
    if attribute_name
      i18n_attr_key2 = "activerecord.attributes.#{model_key}.#{attribute_name}"
      label2 = I18n.exists?(i18n_attr_key2) ? I18n.t(i18n_attr_key2) : nil
      return label2 if label2.present?
    end

    # Fallback to humanized attribute/association
    attr.humanize
  end
end
