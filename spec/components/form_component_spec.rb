# frozen_string_literal: true

require "rails_helper"

RSpec.describe FormComponent, type: :component do
  let(:user) { build(:user) }

  it "renders form" do
    render_inline(described_class.new(model: user, url: users_path)) do
      "Form fields"
    end

    expect(page).to have_selector('form')
  end

  it "renders form with correct action" do
    render_inline(described_class.new(model: user, url: users_path)) do
      "Form fields"
    end

    expect(page).to have_selector("form[action='#{users_path}']")
  end

  it "renders form content" do
    render_inline(described_class.new(model: user, url: users_path)) do
      "Custom form content"
    end

    expect(page).to have_content("Custom form content")
  end
end
