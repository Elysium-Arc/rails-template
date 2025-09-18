# frozen_string_literal: true

require "rails_helper"

RSpec.describe SidebarComponent, type: :component do
  it "renders the sidebar" do
    render_inline(described_class.new(current_user: create(:user)))

    expect(page).to have_selector('aside, nav, [data-component="sidebar"]')
  end

  it "renders navigation items" do
    render_inline(described_class.new(current_user: create(:user)))

    expect(page).to have_selector('a, li')
  end
end
