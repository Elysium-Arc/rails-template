# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  subject { described_class }

  let(:admin_role) { create(:role, :admin) }
  let(:admin_user) { create(:user, roles: [admin_role]) }
  let(:regular_user) { create(:user) }
  let(:other_user) { create(:user) }

  permissions :index?, :create?, :destroy? do
    context 'for an admin user' do
      it 'grants access' do
        expect(subject).to permit(admin_user, other_user)
      end
    end

    context 'for a regular user' do
      it 'denies access' do
        expect(subject).not_to permit(regular_user, other_user)
      end
    end
  end

  permissions :show?, :update? do
    context 'for an admin user' do
      it 'grants access to any user' do
        expect(subject).to permit(admin_user, other_user)
      end
    end

    context 'for a regular user viewing their own record' do
      it 'grants access' do
        expect(subject).to permit(regular_user, regular_user)
      end
    end

    context 'for a regular user viewing another user' do
      it 'denies access' do
        expect(subject).not_to permit(regular_user, other_user)
      end
    end
  end

  describe UserPolicy::Scope do
    subject { described_class.new(user, User).resolve }

    before do
      admin_user
      regular_user
      other_user
    end

    context 'for an admin user' do
      let(:user) { admin_user }

      it 'returns all users' do
        expect(subject).to match_array([admin_user, regular_user, other_user])
      end
    end

    context 'for a regular user' do
      let(:user) { regular_user }

      it 'returns only their own record' do
        expect(subject).to eq([regular_user])
      end
    end
  end
end
