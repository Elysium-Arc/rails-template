# frozen_string_literal: true

class PagyComponent < BaseComponent
  attr_reader :pagy, :form_id

  def initialize(pagy:, form_id: nil, **options)
    @pagy = pagy
    @form_id = form_id
    @options = options
  end

  def container_classes
    "pagy-component flex flex-col sm:flex-row items-center justify-between gap-4 mt-6 p-4 bg-base-100 rounded-lg border border-base-200/60 shadow-sm"
  end

  def info_classes
    "text-sm font-medium text-base-content/80 order-2 sm:order-1"
  end

  def nav_classes
    "flex items-center gap-1.5 order-1 sm:order-2"
  end

  def page_link_classes(page, current_page)
    base_classes = "btn btn-sm min-h-[2rem] h-8 w-8 p-0 transition-all duration-200"
    if page == current_page
      "#{base_classes} btn-primary font-bold shadow-sm"
    else
      "#{base_classes} btn-ghost hover:btn-primary hover:btn-outline font-medium"
    end
  end

  def nav_button_classes
    "btn btn-sm gap-1.5 transition-all duration-200 hover:shadow-sm"
  end

  def disabled_button_classes
    "btn btn-sm btn-disabled gap-1.5 opacity-40 cursor-not-allowed"
  end

  def gap_classes
    "px-1.5 text-base-content/40 font-medium select-none"
  end

  def items_per_page_classes
    "flex items-center gap-2.5 bg-base-200/30 px-3 py-1.5 rounded-lg order-3 sm:order-3"
  end

  def is_rtl?
    I18n.locale.to_s == "ar"
  end
end
