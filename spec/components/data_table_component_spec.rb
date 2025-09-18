# frozen_string_literal: true

require "rails_helper"

RSpec.describe DataTableComponent, type: :component do
  let(:users) { create_list(:user, 3) }
  let(:pagy) { Pagy.new(count: 3, page: 1, items: 10) }
  let(:columns) do
    [
      {
        key: :email_address
      }
    ]
  end

  it "renders data table" do
    render_inline(described_class.new(
      data: users,
      pagy: pagy,
      columns: columns
    ))

    expect(page).to have_selector('table')
  end

  it "displays collection items" do
    render_inline(described_class.new(
      data: users,
      pagy: pagy,
      columns: columns
    ))

    users.each do |user|
      expect(page).to have_content(user.email_address)
    end
  end
end
