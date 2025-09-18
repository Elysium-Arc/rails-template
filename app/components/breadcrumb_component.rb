# frozen_string_literal: true

class BreadcrumbComponent < BaseComponent
  attr_reader :items, :separator

  def initialize(items:, separator: nil, **options)
    @items = items.map { |item| BreadcrumbItem.new(item) }
    @separator = separator
    @options = options
  end

  def container_classes
    "breadcrumbs text-sm"
  end

  def list_classes
    "flex flex-wrap items-center gap-2"
  end

  def item_classes(item)
    base_classes = "flex items-center gap-2"

    if item.active?
      "#{base_classes} text-base-content font-medium"
    else
      "#{base_classes} text-base-content/60 hover:text-base-content transition-colors"
    end
  end

  def separator_icon
    @separator || "chevron-right"
  end

  class BreadcrumbItem
    attr_reader :label, :url, :icon, :active

    def initialize(options = {})
      @label = options[:label] || options[:title]
      @url = options[:url] || options[:path]
      @icon = options[:icon]
      @active = options.fetch(:active, false)
    end

    def active?
      @active
    end

    def has_url?
      @url.present?
    end

    def has_icon?
      @icon.present?
    end
  end
end
