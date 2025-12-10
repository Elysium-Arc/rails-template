require 'rails_helper'

RSpec.describe RbacService do
  describe '.create_role' do
    it 'creates a global role' do
      role = RbacService.create_role('admin', 'Administrator role')
      expect(role.name).to eq('admin')
      expect(role.description).to eq('Administrator role')
      expect(role.global?).to be true
    end

    it 'creates a scoped role' do
      role = RbacService.create_role('editor', 'Editor role', 'Post', 1)
      expect(role.resource_type).to eq('Post')
      expect(role.resource_id).to eq(1)
    end
  end

  describe '.find_or_create_role' do
    it 'finds existing role' do
      create(:role, name: 'admin')
      expect { RbacService.find_or_create_role('admin') }.not_to change(Role, :count)
    end

    it 'creates role if not found' do
      expect { RbacService.find_or_create_role('admin') }.to change(Role, :count).by(1)
    end

    it 'normalizes name' do
      role = RbacService.find_or_create_role('ADMIN')
      expect(role.name).to eq('admin')
    end
  end

  describe '.find_role' do
    it 'finds role by name' do
      role = create(:role, name: 'admin')
      found = RbacService.find_role('admin')
      expect(found).to eq(role)
    end

    it 'raises RoleNotFoundError if not found' do
      expect { RbacService.find_role('nonexistent') }.to raise_error(RbacService::RoleNotFoundError)
    end

    it 'finds scoped role' do
      role = create(:role, name: 'editor', resource_type: 'Post', resource_id: 1)
      found = RbacService.find_role('editor', 'Post', 1)
      expect(found).to eq(role)
    end
  end

  describe '.delete_role' do
    it 'deletes role' do
      create(:role, name: 'admin')
      expect { RbacService.delete_role('admin') }.to change(Role, :count).by(-1)
    end
  end

  describe '.create_permission' do
    it 'creates a permission' do
      permission = RbacService.create_permission('read', 'Read permission')
      expect(permission.name).to eq('read')
      expect(permission.description).to eq('Read permission')
    end
  end

  describe '.find_or_create_permission' do
    it 'finds existing permission' do
      create(:permission, name: 'read')
      expect { RbacService.find_or_create_permission('read', 'Read permission') }.not_to change(Permission, :count)
    end

    it 'creates permission if not found' do
      expect { RbacService.find_or_create_permission('read', 'Read permission') }.to change(Permission, :count).by(1)
    end
  end

  describe '.find_permission' do
    it 'finds permission by name' do
      permission = create(:permission, name: 'read')
      found = RbacService.find_permission('read')
      expect(found).to eq(permission)
    end

    it 'raises PermissionNotFoundError if not found' do
      expect { RbacService.find_permission('nonexistent') }.to raise_error(RbacService::PermissionNotFoundError)
    end
  end

  describe '.delete_permission' do
    it 'deletes permission' do
      create(:permission, name: 'read')
      expect { RbacService.delete_permission('read') }.to change(Permission, :count).by(-1)
    end
  end

  describe '.grant_permission_to_role' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    it 'grants permission to role' do
      RbacService.grant_permission_to_role(role.name, permission.name)
      expect(role.reload.permissions).to include(permission)
    end
  end

  describe '.revoke_permission_from_role' do
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    before { role.grant_permission(permission) }

    it 'revokes permission from role' do
      RbacService.revoke_permission_from_role(role.name, permission.name)
      expect(role.reload.permissions).not_to include(permission)
    end
  end

  describe '.grant_role_to_user' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }

    it 'grants role to user' do
      RbacService.grant_role_to_user(user, role.name)
      expect(user.reload.roles).to include(role)
    end

    it 'works with user ID' do
      RbacService.grant_role_to_user(user.id, role.name)
      expect(user.reload.roles).to include(role)
    end

    it 'works with email address' do
      RbacService.grant_role_to_user(user.email_address, role.name)
      expect(user.reload.roles).to include(role)
    end
  end

  describe '.revoke_role_from_user' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }

    before { user.grant_role(role) }

    it 'revokes role from user' do
      RbacService.revoke_role_from_user(user, role.name)
      expect(user.reload.roles).not_to include(role)
    end
  end

  describe '.user_has_role?' do
    let(:user) { create(:user) }
    let(:role) { create(:role, name: 'admin') }

    it 'returns true if user has role' do
      user.grant_role(role)
      expect(RbacService.user_has_role?(user, 'admin')).to be true
    end

    it 'returns false if user does not have role' do
      expect(RbacService.user_has_role?(user, 'admin')).to be false
    end
  end

  describe '.user_has_permission?' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }
    let(:permission) { create(:permission) }

    before do
      user.grant_role(role)
      role.grant_permission(permission)
    end

    it 'returns true if user has permission through role' do
      expect(RbacService.user_has_permission?(user, permission.name)).to be true
    end

    it 'returns false if user does not have permission' do
      expect(RbacService.user_has_permission?(user, 'nonexistent')).to be false
    end
  end

  describe '.user_permissions' do
    let(:user) { create(:user) }
    let(:role) { create(:role) }
    let(:permissions) { create_list(:permission, 3) }

    before do
      user.grant_role(role)
      permissions.each { |p| role.grant_permission(p) }
    end

    it 'returns list of user permissions' do
      user_perms = RbacService.user_permissions(user)
      expect(user_perms).to match_array(permissions.map(&:name))
    end
  end

  describe '.user_roles' do
    let(:user) { create(:user) }
    let(:roles) { create_list(:role, 3) }

    before do
      roles.each { |r| user.grant_role(r) }
    end

    it 'returns list of user roles' do
      user_roles = RbacService.user_roles(user)
      expect(user_roles).to match_array(roles.map(&:name))
    end
  end
end
