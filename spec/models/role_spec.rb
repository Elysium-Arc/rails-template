require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:role_permissions).dependent(:destroy) }
    it { is_expected.to have_many(:permissions).through(:role_permissions) }
    it { is_expected.to have_many(:user_roles).dependent(:destroy) }
    it { is_expected.to have_many(:users).through(:user_roles) }
  end

  describe 'validations' do
    subject { build(:role) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:description).is_at_most(1000) }

    describe 'uniqueness of name' do
      context 'global role' do
        it 'validates uniqueness' do
          create(:role, name: 'admin')
          expect(build(:role, name: 'admin')).not_to be_valid
        end
      end

      context 'scoped role' do
        it 'allows duplicate names for different resources' do
          create(:role, name: 'editor', resource_type: 'Project', resource_id: 1)
          expect(build(:role, name: 'editor', resource_type: 'Project', resource_id: 2)).to be_valid
        end

        it 'prevents duplicate names for same resource' do
          create(:role, name: 'editor', resource_type: 'Project', resource_id: 1)
          expect(build(:role, name: 'editor', resource_type: 'Project', resource_id: 1)).not_to be_valid
        end
      end
    end
  end

  describe '#global?' do
    it 'returns true for global roles' do
      role = build(:role, resource_type: nil, resource_id: nil)
      expect(role.global?).to be true
    end

    it 'returns false for scoped roles' do
      role = build(:role, resource_type: 'Project', resource_id: 1)
      expect(role.global?).to be false
    end
  end

  describe '#scoped?' do
    it 'returns false for global roles' do
      role = build(:role, resource_type: nil, resource_id: nil)
      expect(role.scoped?).to be false
    end

    it 'returns true for scoped roles' do
      role = build(:role, resource_type: 'Project', resource_id: 1)
      expect(role.scoped?).to be true
    end
  end

  describe '#grant_permission' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    it 'adds permission to role' do
      role.grant_permission(permission)
      expect(role.permissions).to include(permission)
    end

    it 'does not duplicate permission' do
      role.grant_permission(permission)
      role.grant_permission(permission)
      expect(role.permissions.count).to eq(1)
    end
  end

  describe '#revoke_permission' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    before { role.grant_permission(permission) }

    it 'removes permission from role' do
      role.revoke_permission(permission)
      expect(role.permissions).not_to include(permission)
    end
  end

  describe '#has_permission?' do
    let(:role) { create(:role) }

    context 'with global permission' do
      let(:permission) { create(:permission, name: 'read') }

      it 'returns true if role has permission' do
        role.grant_permission(permission)
        expect(role.has_permission?('read')).to be true
      end

      it 'returns false if role does not have permission' do
        expect(role.has_permission?('write')).to be false
      end
    end

    context 'with resource-scoped permission' do
      let(:permission) { create(:permission, name: 'edit', resource_type: 'Post', resource_id: 1) }

      it 'returns true if role has scoped permission' do
        role.grant_permission(permission)
        expect(role.has_permission?('edit', 'Post', 1)).to be true
      end

      it 'returns false if resource does not match' do
        role.grant_permission(permission)
        expect(role.has_permission?('edit', 'Post', 2)).to be false
      end
    end
  end

  describe 'scopes' do
    before do
      @global_role = create(:role, name: 'global')
      @scoped_role = create(:role, name: 'scoped', resource_type: 'Project', resource_id: 1)
    end

    describe '.global' do
      it 'returns only global roles' do
        expect(Role.global).to include(@global_role)
        expect(Role.global).not_to include(@scoped_role)
      end
    end

    describe '.scoped_to' do
      it 'returns roles scoped to specific resource' do
        expect(Role.scoped_to('Project', 1)).to include(@scoped_role)
        expect(Role.scoped_to('Project', 1)).not_to include(@global_role)
      end
    end

    describe '.by_name' do
      it 'finds role by name' do
        expect(Role.by_name('global')).to include(@global_role)
      end

      it 'is case-insensitive' do
        expect(Role.by_name('GLOBAL')).to include(@global_role)
      end
    end
  end
end
