# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Authorization Concern', type: :controller do
  controller(ApplicationController) do
    def with_permission
      authorize_with_permission!('test.action')
      render json: { message: 'success' }
    end

    def with_role
      authorize_with_role!('admin')
      render json: { message: 'success' }
    end

    def with_any_permission
      authorize_with_any_permission!(['action.one', 'action.two'])
      render json: { message: 'success' }
    end

    def with_all_permissions
      authorize_with_all_permissions!(['action.one', 'action.two'])
      render json: { message: 'success' }
    end

    def admin_only
      authorize_admin!
      render json: { message: 'success' }
    end
  end

  before do
    allow(controller).to receive(:current_user).and_return(user)
    routes.draw do
      get :with_permission, to: 'application#with_permission'
      get :with_role, to: 'application#with_role'
      get :with_any_permission, to: 'application#with_any_permission'
      get :with_all_permissions, to: 'application#with_all_permissions'
      get :admin_only, to: 'application#admin_only'
    end
  end

  describe '#authorize_with_permission!' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }
    let(:permission) { create(:permission, name: 'test.action') }

    context 'when user has permission' do
      before do
        role.grant_permission(permission)
        user.grant_role(role)
      end

      it 'allows access' do
        get :with_permission
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('success')
      end
    end

    context 'when user does not have permission' do
      it 'denies access' do
        get :with_permission
        expect(response).to have_http_status(:redirect)
      end
    end

    context 'when user is nil' do
      let(:user) { nil }

      it 'denies access' do
        get :with_permission
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#authorize_with_role!' do
    let(:user) { create(:user) }
    let(:admin_role) { create(:role, name: 'admin') }

    context 'when user has role' do
      before { user.grant_role(admin_role) }

      it 'allows access' do
        get :with_role
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)['message']).to eq('success')
      end
    end

    context 'when user does not have role' do
      it 'denies access' do
        get :with_role
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#authorize_with_any_permission!' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }

    context 'when user has one of the permissions' do
      before do
        perm = create(:permission, name: 'action.one')
        role.grant_permission(perm)
        user.grant_role(role)
      end

      it 'allows access' do
        get :with_any_permission
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user has none of the permissions' do
      it 'denies access' do
        get :with_any_permission
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#authorize_with_all_permissions!' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }

    context 'when user has all permissions' do
      before do
        perm1 = create(:permission, name: 'action.one')
        perm2 = create(:permission, name: 'action.two')
        role.grant_permission(perm1)
        role.grant_permission(perm2)
        user.grant_role(role)
      end

      it 'allows access' do
        get :with_all_permissions
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is missing a permission' do
      before do
        perm = create(:permission, name: 'action.one')
        role.grant_permission(perm)
        user.grant_role(role)
      end

      it 'denies access' do
        get :with_all_permissions
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe '#authorize_admin!' do
    let(:user) { create(:user) }
    let(:admin_role) { create(:role, name: 'admin') }

    context 'when user is admin' do
      before { user.grant_role(admin_role) }

      it 'allows access' do
        get :admin_only
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when user is not admin' do
      it 'denies access' do
        get :admin_only
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe 'Helper methods in views' do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: 'editor') }
    let(:permission) { create(:permission, name: 'post.create') }

    before do
      role.grant_permission(permission)
      user.grant_role(role)
      allow(controller).to receive(:current_user).and_return(user)
    end

    it '#current_user_has_permission? works in view context' do
      expect(controller.current_user_has_permission?('post.create')).to be true
      expect(controller.current_user_has_permission?('post.delete')).to be false
    end

    it '#current_user_has_role? works in view context' do
      expect(controller.current_user_has_role?('editor')).to be true
      expect(controller.current_user_has_role?('admin')).to be false
    end

    it '#current_user_admin? works in view context' do
      expect(controller.current_user_admin?).to be false

      admin_role = create(:role, name: 'admin')
      user.grant_role(admin_role)

      expect(controller.current_user_admin?).to be true
    end
  end
end
