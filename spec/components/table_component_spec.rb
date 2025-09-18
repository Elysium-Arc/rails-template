# frozen_string_literal: true

require "rails_helper"

RSpec.describe TableComponent, type: :component do
  let(:users) { create_list(:user, 3) }
  let(:columns) { [ { key: :email_address } ] }
  it "renders table" do
    render_inline(described_class.new(columns: columns, data: users)) { "Table content" }

    expect(page).to have_selector('table')
  end

  it "renders table columns" do
    render_inline(described_class.new(table_id: 'custom-table', columns: columns, data: users)) { "Content" }

    users.each do |user|
      expect(page).to have_content(user.email_address)
    end
  end

  it "renders with custom ID" do
    render_inline(described_class.new(table_id: 'custom-table', columns: columns, data: users)) { "Content" }

    expect(page).to have_selector('#custom-table')
  end
end
