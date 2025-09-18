# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  let(:flash) { {} }

  it "renders flash messages" do
    flash[:notice] = "Test message"
    render_inline(described_class.new(flash: flash))
    expect(page).to have_content("Test message")
  end

  it "positions flash on the right for LTR languages" do
    flash[:notice] = "Test message"
    render_inline(described_class.new(flash: flash))
    expect(page).to have_css("section.fixed.top-20.right-4.z-50")
  end

  it "positions flash on the left for RTL languages" do
    allow(I18n).to receive(:locale).and_return(:ar)
    flash[:notice] = "Test message"
    render_inline(described_class.new(flash: flash))
    expect(page).to have_css("section.fixed.top-20.left-4.z-50")
  end

  it "applies correct alert styling" do
    flash[:alert] = "Error message"
    render_inline(described_class.new(flash: flash))
    expect(page).to have_css(".alert-error")
  end
end
