require 'rails_helper'

RSpec.describe DashboardController, type: :controller do
  let(:user) { create(:user) }

  before do
    sign_in_as user
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'renders the index template' do
      get :index
      expect(response).to render_template(:index)
    end
  end
end
