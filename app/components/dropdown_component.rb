# frozen_string_literal: true

class DropdownComponent < BaseComponent
  renders_one :trigger
  renders_one :menu

  def initialize(container_classes: "", replace_container_classes: false, dropdown_classes: "", replace_dropdown_classes: false, menu_classes: "", replace_menu_classes: false, direction: :ltr)
    direction_class = direction == :rtl ? "dropdown-start" : "dropdown-end"
    @container_classes = replace_container_classes ? container_classes : "dropdown #{direction_class} #{container_classes}"
    @dropdown_classes = replace_dropdown_classes ? dropdown_classes : "btn m-1 #{dropdown_classes}"
    # High z-index to ensure dropdowns appear above table content
    @menu_classes = replace_menu_classes ? menu_classes : "dropdown-content menu bg-base-200 rounded-box z-[1000] w-52 p-2 shadow-lg border border-base-300 #{menu_classes}"
  end
end
