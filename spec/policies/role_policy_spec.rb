# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolePolicy, type: :policy do
  subject { described_class }

  let(:admin_role) { create(:role, :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:regular_user) { create(:user) }
  let(:role) { create(:role) }

  permissions :index?, :show?, :create?, :update?, :destroy? do
    context 'for an admin user' do
      it 'grants access' do
        expect(subject).to permit(admin_user, role)
      end
    end

    context 'for a regular user' do
      it 'denies access' do
        expect(subject).not_to permit(regular_user, role)
      end
    end
  end

  describe RolePolicy::Scope do
    subject { described_class.new(user, Role).resolve }

    context 'for an admin user' do
      let(:user) { admin_user }

      it 'returns all roles' do
        expect(subject).to eq(Role.all)
      end
    end

    context 'for a regular user' do
      let(:user) { regular_user }

      it 'returns no roles' do
        expect(subject).to be_empty
      end
    end
  end
end
