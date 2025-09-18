# frozen_string_literal: true

require "rails_helper"

RSpec.describe TopbarComponent, type: :component do
  let(:user) { create(:user) }

  before do
    allow_any_instance_of(LanguageDropdownComponent).to receive(:request).and_return(
      double('request', query_parameters: {}, path_parameters: {}, path: '/', fullpath: '/')
    )

    allow_any_instance_of(TopbarComponent).to receive(:request).and_return(
      double('request', query_parameters: {}, path_parameters: {}, path: '/', fullpath: '/')
    )
  end

  it "renders the topbar" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_selector('header, nav, [data-component="topbar"]')
  end

  it "displays user email" do
    render_inline(described_class.new(current_user: user))

    expect(page).to have_content(user.email_address)
  end
end
