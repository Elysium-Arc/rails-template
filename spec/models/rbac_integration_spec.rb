require 'rails_helper'

RSpec.describe 'RBAC Integration', type: :model do
  describe 'User with Roles and Permissions' do
    let(:user) { create(:user) }
    let(:admin_role) { create(:role, name: 'admin') }
    let(:editor_role) { create(:role, name: 'editor') }
    let(:viewer_role) { create(:role, name: 'viewer') }

    let(:create_perm) { create(:permission, name: 'post.create') }
    let(:edit_perm) { create(:permission, name: 'post.edit') }
    let(:delete_perm) { create(:permission, name: 'post.delete') }
    let(:read_perm) { create(:permission, name: 'post.read') }

    before do
      admin_role.grant_permission(create_perm)
      admin_role.grant_permission(edit_perm)
      admin_role.grant_permission(delete_perm)

      editor_role.grant_permission(create_perm)
      editor_role.grant_permission(edit_perm)

      viewer_role.grant_permission(read_perm)
    end

    describe 'role management' do
      it 'assigns and revokes roles' do
        user.grant_role(admin_role)
        expect(user.roles).to include(admin_role)

        user.revoke_role(admin_role)
        expect(user.roles).not_to include(admin_role)
      end

      it 'prevents duplicate role assignments' do
        user.grant_role(admin_role)
        user.grant_role(admin_role)
        expect(user.roles.count).to eq(1)
      end
    end

    describe 'permission checking through roles' do
      context 'with admin role' do
        before { user.grant_role(admin_role) }

        it 'has all admin permissions' do
          expect(user.has_permission?('post.create')).to be true
          expect(user.has_permission?('post.edit')).to be true
          expect(user.has_permission?('post.delete')).to be true
        end

        it 'does not have viewer permissions' do
          expect(user.has_permission?('post.read')).to be false
        end

        it 'is admin' do
          expect(user.admin?).to be true
        end
      end

      context 'with editor role' do
        before { user.grant_role(editor_role) }

        it 'has create and edit but not delete' do
          expect(user.has_permission?('post.create')).to be true
          expect(user.has_permission?('post.edit')).to be true
          expect(user.has_permission?('post.delete')).to be false
        end

        it 'is not admin' do
          expect(user.admin?).to be false
        end
      end

      context 'with multiple roles' do
        before do
          user.grant_role(editor_role)
          user.grant_role(viewer_role)
        end

        it 'has permissions from all roles' do
          expect(user.has_permission?('post.create')).to be true
          expect(user.has_permission?('post.edit')).to be true
          expect(user.has_permission?('post.read')).to be true
          expect(user.has_permission?('post.delete')).to be false
        end
      end
    end

    describe 'permission listing' do
      before do
        user.grant_role(editor_role)
        user.grant_role(viewer_role)
      end

      it 'lists all permissions for user' do
        perms = user.permissions_list
        expect(perms).to include('post.create')
        expect(perms).to include('post.edit')
        expect(perms).to include('post.read')
        expect(perms).not_to include('post.delete')
      end

      it 'lists all roles for user' do
        roles = user.roles_list
        expect(roles).to include('editor')
        expect(roles).to include('viewer')
        expect(roles).not_to include('admin')
      end
    end

    describe 'permission checking variants' do
      before { user.grant_role(admin_role) }

      it 'checks any of multiple permissions' do
        result = user.has_any_permission?(['post.create', 'post.unknown'])
        expect(result).to be true
      end

      it 'returns false if none match' do
        result = user.has_any_permission?(['unknown.action', 'another.unknown'])
        expect(result).to be false
      end

      it 'checks all permissions' do
        result = user.has_all_permissions?(['post.create', 'post.edit'])
        expect(result).to be true
      end

      it 'returns false if not all match' do
        result = user.has_all_permissions?(['post.create', 'post.read'])
        expect(result).to be false
      end
    end
  end

  describe 'Resource-scoped roles and permissions' do
    let(:user) { create(:user) }
    let(:moderator_role) { create(:role, name: 'post_moderator', resource_type: 'Post', resource_id: 1) }
    let(:moderate_perm) { create(:permission, name: 'moderate', resource_type: 'Post', resource_id: 1) }

    before do
      moderator_role.grant_permission(moderate_perm)
      user.grant_role(moderator_role)
    end

    it 'checks scoped role' do
      expect(user.has_role?('post_moderator', 'Post', 1)).to be true
      expect(user.has_role?('post_moderator', 'Post', 2)).to be false
    end

    it 'checks scoped permission' do
      expect(user.has_permission?('moderate', 'Post', 1)).to be true
      expect(user.has_permission?('moderate', 'Post', 2)).to be false
    end

    it 'lists scoped roles' do
      scoped_roles = user.roles_list('Post', 1)
      expect(scoped_roles).to include('post_moderator')
    end

    it 'lists scoped permissions' do
      scoped_perms = user.permissions_list('Post', 1)
      expect(scoped_perms).to include('moderate')
    end
  end

  describe 'RbacService integration' do
    let(:user) { create(:user, email_address: 'test@example.com') }

    it 'creates and assigns roles through service' do
      RbacService.create_role('content_manager', 'Manages content')
      RbacService.create_permission('content.manage', 'Manage content')

      RbacService.grant_permission_to_role('content_manager', 'content.manage')
      RbacService.grant_role_to_user(user, 'content_manager')

      expect(RbacService.user_has_permission?(user, 'content.manage')).to be true
      expect(RbacService.user_has_role?(user, 'content_manager')).to be true
    end

    it 'finds user by email' do
      RbacService.create_role('moderator', 'Moderates content')
      RbacService.grant_role_to_user(user.email_address, 'moderator')

      expect(user.reload.roles.count).to eq(1)
      expect(user.has_role?('moderator')).to be true
    end

    it 'queries user permissions' do
      RbacService.create_role('admin', 'Administrator')
      RbacService.create_permission('users.manage', 'Manage users')
      RbacService.create_permission('system.configure', 'Configure system')

      admin = RbacService.find_role('admin')
      users_perm = RbacService.find_permission('users.manage')
      system_perm = RbacService.find_permission('system.configure')

      admin.grant_permission(users_perm)
      admin.grant_permission(system_perm)

      RbacService.grant_role_to_user(user, 'admin')

      perms = RbacService.user_permissions(user)
      expect(perms).to include('users.manage', 'system.configure')
    end
  end
end
