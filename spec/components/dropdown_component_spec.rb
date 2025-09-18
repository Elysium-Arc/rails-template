# frozen_string_literal: true

require "rails_helper"

RSpec.describe DropdownComponent, type: :component do
  it "renders dropdown" do
    render_inline(described_class.new) do |component|
      component.with_trigger do
        "Trigger"
      end

      component.with_menu do
        "Menu"
      end
    end

    expect(page).to have_content("Trigger")
    expect(page).to have_content("Menu")
  end
end
