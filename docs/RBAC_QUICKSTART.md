# RBAC Quick Start Guide

This guide shows you how to quickly get started with the Role-Based Access Control (RBAC) system in your Pulsar application.

## Setup

### 1. Run Migrations

```bash
./bin/rails db:migrate
```

This creates the following tables:
- `roles` - Store role definitions
- `permissions` - Store permission definitions
- `role_permissions` - Join table for roles and permissions
- `user_roles` - Join table for users and roles

### 2. Seed Default Roles and Permissions

```bash
./bin/rails rbac:seed
```

This creates default roles (admin, user, manager, moderator, viewer) and permissions with proper assignments.

## Basic Usage

### Creating Roles and Permissions

**Option 1: Using the RBAC Service (Recommended)**

```ruby
# Create a role
role = RbacService.create_role('editor', 'Content editor role')

# Create a permission
permission = RbacService.create_permission('post.create', 'Can create posts')

# Grant permission to role
RbacService.grant_permission_to_role('editor', 'post.create')

# Assign role to user
user = User.find(1)
RbacService.grant_role_to_user(user, 'editor')
```

**Option 2: Using Rails Console**

```ruby
role = Role.create!(name: 'admin', description: 'Admin role')
permission = Permission.create!(name: 'user.create', description: 'Can create users')
role.grant_permission(permission)
```

### Checking Permissions

```ruby
user = User.find(1)

# Check if user has a specific role
user.has_role?('admin')

# Check if user has a specific permission (through their roles)
user.has_permission?('post.create')

# Check multiple permissions
user.has_any_permission?(['post.create', 'post.edit'])
user.has_all_permissions?(['post.create', 'post.publish'])

# Check if user is admin
user.admin?

# Get all roles
user.roles_list

# Get all permissions
user.permissions_list
```

### Using in Controllers

```ruby
class PostsController < ApplicationController
  def create
    # Require a specific permission
    authorize_with_permission!('post.create')
    
    @post = Post.create!(post_params)
    render json: @post
  end

  def destroy
    # Require admin role
    authorize_admin!
    
    @post = Post.find(params[:id])
    @post.destroy
  end

  def update
    # Require any of these permissions
    authorize_with_any_permission!(['post.edit', 'post.manage'])
    
    @post = Post.find(params[:id])
    @post.update!(post_params)
  end
end
```

### Using in Views

```erb
<% if current_user_has_permission?('post.create') %>
  <%= link_to 'New Post', new_post_path, class: 'btn btn-primary' %>
<% end %>

<% if current_user_admin? %>
  <%= link_to 'Admin Panel', admin_path %>
<% end %>

<% if current_user_has_role?('editor') %>
  <%= link_to 'Editor Tools', editor_path %>
<% end %>
```

### Using with Pundit Policies

```ruby
class PostPolicy < ApplicationPolicy
  def create?
    user.has_permission?('post.create')
  end

  def update?
    user.has_permission?('post.update')
  end

  def destroy?
    user.has_permission?('post.delete') || user.admin?
  end
end
```

## Managing Roles and Permissions via UI

The system includes admin controllers for managing roles and permissions:

- **Roles Index**: `/roles`
- **Create Role**: `/roles/new`
- **Edit Role**: `/roles/:id/edit`
- **Permissions Index**: `/permissions`
- **Create Permission**: `/permissions/new`
- **Edit Permission**: `/permissions/:id/edit`

> **Note:** Only users with appropriate permissions can access these pages.

## Rake Tasks

### View Available Tasks

```bash
./bin/rake -T rbac
```

### Common Tasks

```bash
# Seed default roles and permissions
./bin/rails rbac:seed

# Create a new role
./bin/rails rbac:role:create[editor,"Content editor role"]

# Create a new permission
./bin/rails rbac:permission:create[post.create,"Can create posts"]

# Grant permission to role
./bin/rails rbac:grant:permission[editor,post.create]

# Grant role to user (by email)
./bin/rails rbac:grant:role[user@example.com,editor]

# Revoke permission from role
./bin/rails rbac:revoke:permission[editor,post.delete]

# Revoke role from user
./bin/rails rbac:revoke:role[user@example.com,editor]

# Show user's roles and permissions
./bin/rails rbac:user:show[user@example.com]

# List all roles
./bin/rails rbac:role:list

# List all permissions
./bin/rails rbac:permission:list
```

## Resource-Scoped Permissions

For fine-grained control, you can scope roles and permissions to specific resources:

```ruby
# Create a resource-scoped role
role = RbacService.create_role('post_editor', 'Can edit post #1', 'Post', 1)

# Create a resource-scoped permission
permission = RbacService.create_permission(
  'edit',
  'Can edit this post',
  'Post',
  1
)

# Grant to role
role.grant_permission(permission)

# Check scoped permission
user.has_permission?('edit', 'Post', 1)  # true
user.has_permission?('edit', 'Post', 2)  # false
```

## Common Patterns

### Pattern 1: Admin-Only Actions

```ruby
class UsersController < ApplicationController
  before_action :authorize_admin!, only: [:destroy]

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    redirect_to users_path
  end
end
```

### Pattern 2: Permission-Based Feature Flags

```ruby
class PostsController < ApplicationController
  def new
    unless current_user_has_permission?('post.create')
      redirect_to posts_path, alert: 'Not authorized'
    end
  end
end
```

### Pattern 3: Multiple Permission Requirement

```ruby
class CommentsController < ApplicationController
  def publish
    # User must have ALL these permissions
    authorize_with_all_permissions!(['comment.create', 'comment.publish'])
  end

  def moderate
    # User must have at least ONE of these permissions
    authorize_with_any_permission!(['comment.approve', 'comment.reject', 'comment.delete'])
  end
end
```

## Testing with RBAC

```ruby
describe PostsController do
  let(:user) { create(:user) }
  let(:admin_role) { create(:role, name: 'admin') }
  let(:editor_role) { create(:role, name: 'editor') }
  let(:permission) { create(:permission, name: 'post.create') }

  describe '#create' do
    context 'with proper permission' do
      before do
        editor_role.grant_permission(permission)
        user.grant_role(editor_role)
      end

      it 'creates a post' do
        expect {
          post :create, params: { post: { title: 'Test' } }
        }.to change(Post, :count).by(1)
      end
    end

    context 'without permission' do
      it 'denies access' do
        post :create, params: { post: { title: 'Test' } }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
```

## Best Practices

1. **Use Consistent Permission Names**: Use dot notation (e.g., `post.create`, `user.delete`)

2. **Create Permissions First**: Define all permissions before assigning to roles

3. **Use Service Methods**: Use `RbacService` for operations instead of manipulating models directly

4. **Check in Policies**: Always check permissions in Pundit policies, not just controllers

5. **Test Authorization**: Write tests for your authorization logic

6. **Document Permissions**: Keep a list of all permissions your app uses

7. **Use Meaningful Names**: Role and permission names should clearly describe what they do

## Troubleshooting

### User Not Getting Expected Permissions

Check that:
1. Role is assigned: `user.has_role?('role_name')`
2. Permission is assigned to role: `role.has_permission?('permission.name')`
3. Names match (matching is case-insensitive)

### Permission Check Always Fails

Verify:
1. Permission exists: `Permission.exists?(name: 'permission.name')`
2. Permission is granted to a role that user has
3. For scoped permissions, both `resource_type` and `resource_id` must match

### Performance Issues

Use eager loading:

```ruby
users = User.includes(roles: :permissions).all
```

## Next Steps

- Read the [Comprehensive RBAC Documentation](RBAC.md)
- Explore the generated code in `app/models/role.rb`, `app/services/rbac_service.rb`
- Check out the specs in `spec/` for more usage examples
- Set up your custom roles and permissions for your app

## Support

For issues or questions:
1. Check the [RBAC Documentation](RBAC.md)
2. Look at the specs in `spec/` for examples
3. Review the rake tasks for common operations
