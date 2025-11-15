# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it { should have_many(:role_permissions).dependent(:destroy) }
    it { should have_many(:permissions).through(:role_permissions) }
    it { should have_many(:user_roles).dependent(:destroy) }
    it { should have_many(:users).through(:user_roles) }
    it { should belong_to(:resource).optional }
  end

  describe 'validations' do
    subject { build(:role) }

    it { should validate_presence_of(:name) }

    context 'uniqueness' do
      before { create(:role, name: 'admin') }

      it 'validates uniqueness of name scoped to resource' do
        expect(build(:role, name: 'admin')).not_to be_valid
      end
    end

    it 'validates name format' do
      expect(build(:role, name: 'invalid-name')).not_to be_valid
      expect(build(:role, name: 'InvalidName')).not_to be_valid
      expect(build(:role, name: 'valid_name')).to be_valid
    end
  end

  describe 'scopes' do
    let!(:global_role) { create(:role, resource_type: nil, resource_id: nil) }
    let!(:scoped_role) { create(:role, :scoped) }

    describe '.global' do
      it 'returns only global roles' do
        expect(Role.global).to include(global_role)
        expect(Role.global).not_to include(scoped_role)
      end
    end

    describe '.scoped_to' do
      it 'returns roles scoped to a resource' do
        user = User.create!(email_address: 'test@example.com', password: 'password123')
        role = create(:role, resource_type: 'User', resource_id: user.id)

        expect(Role.scoped_to(user)).to include(role)
        expect(Role.scoped_to(user)).not_to include(global_role)
      end
    end
  end

  describe '#has_permission?' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission, name: 'users.create') }

    before do
      create(:role_permission, role: role, permission: permission)
    end

    it 'returns true when role has the permission' do
      expect(role.has_permission?('users.create')).to be true
    end

    it 'returns false when role does not have the permission' do
      expect(role.has_permission?('users.destroy')).to be false
    end
  end

  describe '#global?' do
    it 'returns true for global roles' do
      role = create(:role, resource_type: nil, resource_id: nil)
      expect(role.global?).to be true
    end

    it 'returns false for scoped roles' do
      role = create(:role, :scoped)
      expect(role.global?).to be false
    end
  end

  describe '#scoped?' do
    it 'returns false for global roles' do
      role = create(:role, resource_type: nil, resource_id: nil)
      expect(role.scoped?).to be false
    end

    it 'returns true for scoped roles' do
      role = create(:role, :scoped)
      expect(role.scoped?).to be true
    end
  end

  describe '#display_name' do
    it 'returns humanized name' do
      role = create(:role, name: 'super_admin')
      expect(role.display_name).to eq('Super admin')
    end
  end

  describe '#full_display_name' do
    it 'returns display name for global roles' do
      role = create(:role, name: 'admin')
      expect(role.full_display_name).to eq('Admin')
    end

    it 'returns display name with resource info for scoped roles' do
      role = create(:role, name: 'manager', resource_type: 'User', resource_id: 1)
      expect(role.full_display_name).to eq('Manager (User #1)')
    end
  end
end
