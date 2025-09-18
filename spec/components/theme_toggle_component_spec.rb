# frozen_string_literal: true

require "rails_helper"

RSpec.describe ThemeToggleComponent, type: :component do
  it "renders the theme toggle" do
    render_inline(described_class.new)

    expect(page).to have_selector('[data-controller="theme"]')
  end

  it "renders toggle button" do
    render_inline(described_class.new)

    expect(page).to have_button
  end
end
