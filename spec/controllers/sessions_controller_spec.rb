# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  describe 'GET #new' do
    context 'when not authenticated' do
      it 'returns success' do
        get :new
        expect(response).to be_successful
      end

      it 'renders the new template' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'when already authenticated' do
      let(:user) { create(:user) }

      before do
        allow(controller).to receive(:authenticated?).and_return(true)
      end

      it 'redirects to root path' do
        get :new
        expect(response).to redirect_to(root_path(I18n.locale))
      end
    end
  end

  describe 'POST #create' do
    let(:user) { create(:user, email_address: 'test@example.com', password: 'password123') }

    context 'with valid credentials' do
      let(:valid_params) do
        { session: { email_address: user.email_address, password: 'password123' } }
      end

      before do
        allow(User).to receive(:authenticate_by)
          .with(hash_including(email_address: user.email_address, password: 'password123'))
          .and_return(user)
      end

      it 'authenticates the user' do
        allow(controller).to receive(:after_authentication_url).and_return(root_path)
        post :create, params: valid_params
        expect(response).to redirect_to(root_path)
      end

      it 'sets a success flash message' do
        post :create, params: valid_params
        expect(flash[:notice]).to eq('flash.sessions.login_success')
      end
    end

    context 'with invalid email' do
      let(:invalid_email_params) do
        { session: { email_address: 'nonexistent@example.com', password: 'password123' } }
      end

      it 'redirects to login path' do
        post :create, params: invalid_email_params
        expect(response).to redirect_to(login_path)
      end

      it 'sets an error flash message' do
        post :create, params: invalid_email_params
        expect(flash[:alert]).to be_present
      end
    end

    context 'with invalid password' do
      let(:invalid_password_params) do
        { session: { email_address: user.email_address, password: 'wrongpassword' } }
      end

      before { user } # Ensure user exists

      it 'redirects to login path' do
        post :create, params: invalid_password_params
        expect(response).to redirect_to(login_path)
      end

      it 'sets an error flash message' do
        post :create, params: invalid_password_params
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'DELETE #destroy' do
    let(:user) { create(:user) }

    before do
      sign_in_as(user)
    end

    it 'terminates the session' do
      expect(controller).to receive(:terminate_session)
      delete :destroy
    end

    it 'redirects to login path' do
      delete :destroy
      expect(response).to redirect_to(login_path)
    end

    it 'sets a success flash message' do
      delete :destroy
      expect(flash[:notice]).to eq('flash.sessions.logout_success')
    end
  end
end
