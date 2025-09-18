# frozen_string_literal: true

require "rails_helper"

RSpec.describe PagyComponent, type: :component do
  let(:pagy) { Pagy.new(count: 100, page: 1, items: 10) }

  before do
    fake_request = double(
      'request',
      params: { controller: "users", action: "index" },
      query_parameters: {},
      path_parameters: { controller: "users", action: "index" },
      path: "/users",
      fullpath: "/users"
    )

    allow_any_instance_of(PagyComponent).to receive(:request).and_return(fake_request)
  end

  it "renders pagination" do
    render_inline(described_class.new(pagy: pagy))
    expect(page).to have_selector('nav')
  end

  it "shows page numbers" do
    render_inline(described_class.new(pagy: pagy))
    expect(page).to have_content('1')
  end

  it "handles single page gracefully" do
    single_page_pagy = Pagy.new(count: 5, page: 1, items: 10)
    render_inline(described_class.new(pagy: single_page_pagy))
    expect(page).to have_selector('nav')
  end
end
