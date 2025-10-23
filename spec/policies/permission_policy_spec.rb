# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PermissionPolicy, type: :policy do
  subject { described_class }

  let(:admin_role) { create(:role, :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:regular_user) { create(:user) }
  let(:permission) { create(:permission) }

  permissions :index?, :show?, :create?, :update?, :destroy? do
    context 'for an admin user' do
      it 'grants access' do
        expect(subject).to permit(admin_user, permission)
      end
    end

    context 'for a regular user' do
      it 'denies access' do
        expect(subject).not_to permit(regular_user, permission)
      end
    end
  end

  describe PermissionPolicy::Scope do
    subject { described_class.new(user, Permission).resolve }

    context 'for an admin user' do
      let(:user) { admin_user }

      it 'returns all permissions' do
        expect(subject).to eq(Permission.all)
      end
    end

    context 'for a regular user' do
      let(:user) { regular_user }

      it 'returns no permissions' do
        expect(subject).to be_empty
      end
    end
  end
end
