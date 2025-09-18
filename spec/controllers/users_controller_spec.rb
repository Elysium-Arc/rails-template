# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  let(:user) { create(:user) }
  let(:valid_attributes) do
    { email_address: 'newuser@example.com', password: 'password123', password_confirmation: 'password123' }
  end
  let(:invalid_attributes) do
    { email_address: '', password: 'short' }
  end

  before do
    sign_in_as(user)
  end

  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns users' do
      create_list(:user, 3)
      get :index
      expect(assigns(:users)).to_not be_nil
    end
  end

  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: user.to_param }
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a success response' do
      get :new
      expect(response).to be_successful
    end

    it 'assigns a new user' do
      get :new
      expect(assigns(:user)).to be_a_new(User)
    end
  end

  describe 'GET #edit' do
    it 'returns a success response' do
      get :edit, params: { id: user.to_param }
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new User' do
        expect {
          post :create, params: { user: valid_attributes }
        }.to change(User, :count).by(1)
      end

      it 'redirects to users path on HTML request' do
        post :create, params: { user: valid_attributes }, format: :html
        expect(response).to redirect_to(users_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a new User' do
        expect {
          post :create, params: { user: invalid_attributes }
        }.to_not change(User, :count)
      end

      it 'returns unprocessable entity status' do
        post :create, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      let(:new_attributes) do
        { email_address: 'updated@example.com' }
      end

      it 'updates the requested user' do
        patch :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.email_address).to eq('updated@example.com')
      end

      it 'redirects to users path on HTML request' do
        patch :update, params: { id: user.to_param, user: new_attributes }, format: :html
        expect(response).to redirect_to(users_path)
      end
    end

    context 'with invalid params' do
      it 'does not update the user' do
        original_email = user.email_address
        patch :update, params: { id: user.to_param, user: invalid_attributes }
        user.reload
        expect(user.email_address).to eq(original_email)
      end

      it 'returns unprocessable entity status' do
        patch :update, params: { id: user.to_param, user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when password is blank' do
      it 'updates user without changing password' do
        new_attributes = { email_address: 'newemail@example.com', password: '', password_confirmation: '' }
        patch :update, params: { id: user.to_param, user: new_attributes }
        user.reload
        expect(user.email_address).to eq('newemail@example.com')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested user' do
      user_to_delete = create(:user)
      expect {
        delete :destroy, params: { id: user_to_delete.to_param }
      }.to change(User, :count).by(-1)
    end
  end
end
