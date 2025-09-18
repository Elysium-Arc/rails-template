# frozen_string_literal: true

require "rails_helper"

RSpec.describe LanguageDropdownComponent, type: :component do
  it "shows all available languages with correct translation" do
    render_inline(described_class.new)

    I18n.available_locales.each do |locale|
      translated_name = I18n.t("topbar.languages.#{locale}")
      expect(page).to have_content(translated_name)
    end
  end

  it "marks the current locale as selected" do
    current_locale = I18n.default_locale
    render_inline(described_class.new(current_locale: current_locale))

    selected_text = I18n.t("topbar.languages.#{current_locale}")
    expect(page).to have_selector('span.dropdown-item-selected', text: selected_text)
  end

  it "generates correct links for other locales" do
    current_locale = I18n.default_locale
    render_inline(described_class.new(current_locale: current_locale))

    I18n.available_locales.reject { |l| l == current_locale }.each do |locale|
      expect(page).to have_link(href: /#{locale}/)
    end
  end
end
