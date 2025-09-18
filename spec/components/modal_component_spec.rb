# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModalComponent, type: :component do
  it "renders the modal" do
    render_inline(described_class.new(id: "custom-modal"))

    expect(page).to have_content("Loading...")
  end

  it "renders with custom ID" do
    render_inline(described_class.new(id: "custom-modal"))

    expect(page).to have_selector("#custom-modal")
  end

  it "renders with title" do
    render_inline(described_class.new(id: "custom-modal", title: "Test Modal"))

    expect(page).to have_content("Test Modal")
  end
end
