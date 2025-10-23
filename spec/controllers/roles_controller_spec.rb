# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  let(:admin_role) { create(:role, :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:regular_user) { create(:user) }
  let(:role) { create(:role) }

  describe 'GET #index' do
    context 'when user is admin' do
      before { sign_in admin_user }

      it 'returns success' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns @roles' do
        role
        get :index
        expect(assigns(:roles)).to include(role, admin_role)
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
    let(:valid_attributes) { { name: 'editor', description: 'Content editor role' } }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'creates a new role' do
        expect {
          post :create, params: { role: valid_attributes }, format: :turbo_stream
        }.to change(Role, :count).by(1)
      end

      it 'assigns permissions if provided' do
        permission = create(:permission)
        post :create, params: { 
          role: valid_attributes.merge(permission_ids: [permission.id]) 
        }, format: :turbo_stream
        
        expect(Role.last.permissions).to include(permission)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          post :create, params: { role: valid_attributes }, format: :turbo_stream
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'PATCH #update' do
    let(:new_attributes) { { name: 'updated_role', description: 'Updated description' } }

    context 'when user is admin' do
      before { sign_in admin_user }

      it 'updates the role' do
        patch :update, params: { id: role.id, role: new_attributes }, format: :turbo_stream
        role.reload
        expect(role.name).to eq('updated_role')
      end

      it 'updates permissions' do
        permission1 = create(:permission)
        permission2 = create(:permission)
        role.permissions << permission1

        patch :update, params: { 
          id: role.id, 
          role: { permission_ids: [permission2.id] } 
        }, format: :turbo_stream
        
        role.reload
        expect(role.permissions).to contain_exactly(permission2)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          patch :update, params: { id: role.id, role: new_attributes }, format: :turbo_stream
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'when user is admin' do
      before { sign_in admin_user }

      it 'destroys the role' do
        role
        expect {
          delete :destroy, params: { id: role.id }, format: :turbo_stream
        }.to change(Role, :count).by(-1)
      end
    end

    context 'when user is not admin' do
      before { sign_in regular_user }

      it 'raises Pundit::NotAuthorizedError' do
        expect {
          delete :destroy, params: { id: role.id }, format: :turbo_stream
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
