# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionsController, type: :controller do
  let(:admin_role) { create(:role, :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:regular_user) { create(:user) }
  let(:permission) { create(:permission) }

  describe 'GET #index' do
    context 'when user is admin' do
      before { sign_in admin_user }

      it 'returns success' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns @permissions' do
        permission
        get :index
        expect(assigns(:permissions)).to include(permission)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          get :index
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when user is not signed in' do
      it 'redirects to login' do
        get :index
        expect(response).to redirect_to(login_path)
      end
    end
  end

  describe 'POST #create' do
    let(:valid_attributes) { 
      { name: 'articles.publish', description: 'Publish articles' } 
    }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'creates a new permission' do
        expect {
          post :create, params: { permission: valid_attributes }, format: :turbo_stream
        }.to change(Permission, :count).by(1)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          post :create, params: { permission: valid_attributes }, format: :turbo_stream
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { 
      { name: 'articles.edit', description: 'Edit articles' } 
    }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'updates the permission' do
        patch :update, params: { 
          id: permission.id, 
          permission: new_attributes 
        }, format: :turbo_stream
        
        permission.reload
        expect(permission.name).to eq('articles.edit')
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          patch :update, params: { 
            id: permission.id, 
            permission: new_attributes 
          }, format: :turbo_stream
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is admin' do
      before { sign_in admin_user }

      it 'destroys the permission' do
        permission
        expect {
          delete :destroy, params: { id: permission.id }, format: :turbo_stream
        }.to change(Permission, :count).by(-1)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          delete :destroy, params: { id: permission.id }, format: :turbo_stream
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  private

  def sign_in(user)
    session[:user_id] = user.id
    allow(controller).to receive(:current_user).and_return(user)
    allow(Current).to receive(:user).and_return(user)
  end
end
