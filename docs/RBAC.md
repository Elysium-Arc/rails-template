# Role-Based Access Control (RBAC)

This document provides a comprehensive guide to the RBAC (Role-Based Access Control) system in Pulsar.

## Overview

The RBAC system provides a flexible and extensible way to manage user roles and permissions. It supports:

- **Global Roles & Permissions**: Roles and permissions that apply across the entire application
- **Resource-Scoped Roles & Permissions**: Roles and permissions specific to particular resources
- **User Role Assignment**: Easy assignment of roles to users
- **Permission-based Authorization**: Fine-grained access control based on permissions
- **Pundit Integration**: Seamless integration with Pundit for policy-based authorization

## Core Models

### Role

The `Role` model represents a set of permissions. Roles can be global or scoped to specific resources.

```ruby
role = Role.create!(
  name: 'admin',
  description: 'Administrator role',
  resource_type: nil,      # Optional: for scoped roles
  resource_id: nil         # Optional: for scoped roles
)
```

#### Key Methods

- `global?` - Returns true if the role is global
- `scoped?` - Returns true if the role is resource-scoped
- `grant_permission(permission)` - Assign a permission to the role
- `revoke_permission(permission)` - Remove a permission from the role
- `has_permission?(name, resource_type=nil, resource_id=nil)` - Check if role has a permission
- `permissions` - Get all permissions assigned to the role
- `users` - Get all users with this role

### Permission

The `Permission` model represents an action or capability that can be granted to roles.

```ruby
permission = Permission.create!(
  name: 'user.create',
  description: 'Permission to create users'
)
```

#### Key Methods

- `global?` - Returns true if the permission is global
- `scoped?` - Returns true if the permission is resource-scoped
- `roles` - Get all roles with this permission

### UserRole

The `UserRole` model joins users with roles.

```ruby
user.grant_role(role)
user.revoke_role(role)
```

### RolePermission

The `RolePermission` model joins roles with permissions.

```ruby
role.grant_permission(permission)
role.revoke_permission(permission)
```

## User Model Integration

The `User` model includes RBAC methods for role and permission checking:

```ruby
user = User.find(1)

# Check roles
user.has_role?('admin')                              # Check global role
user.has_role?('editor', 'Post', 1)                 # Check scoped role
user.roles_list                                      # Get list of global role names
user.roles_list('Post', 1)                          # Get scoped roles for resource

# Check permissions
user.has_permission?('user.create')                 # Check global permission
user.has_permission?('post.edit', 'Post', 1)       # Check scoped permission
user.has_any_permission?(['post.edit', 'post.delete'], 'Post', 1)
user.has_all_permissions?(['post.edit', 'post.publish'], 'Post', 1)
user.permissions_list('Post', 1)                    # Get all permissions for resource

# Manage roles
user.grant_role(role)
user.revoke_role(role)
user.admin?                                          # Shorthand for admin role
```

## RBAC Service

The `RbacService` provides high-level methods for managing roles and permissions:

```ruby
# Create roles and permissions
RbacService.create_role('editor', 'Content editor')
RbacService.create_permission('post.create', 'Permission to create posts')

# Find or create (useful for seeding)
role = RbacService.find_or_create_role('admin', 'Administrator role')
permission = RbacService.find_or_create_permission('user.delete', 'Delete users')

# Grant/revoke permissions from roles
RbacService.grant_permission_to_role('editor', 'post.create')
RbacService.revoke_permission_from_role('editor', 'post.delete')

# Manage user roles
RbacService.grant_role_to_user(user, 'editor')
RbacService.grant_role_to_user(user.id, 'editor')
RbacService.grant_role_to_user(user.email_address, 'editor')

# Query user permissions
RbacService.user_has_role?(user, 'admin')
RbacService.user_has_permission?(user, 'post.create')
RbacService.user_permissions(user)                  # Get all permission names
RbacService.user_roles(user)                        # Get all role names
```

## Controller Authorization

Use the `Authorization` concern in controllers for easy access control:

```ruby
class PostsController < ApplicationController
  before_action :authorize_admin!, only: [:destroy]
  before_action :authorize_with_permission!, only: [:create]

  def index
    # Only users with 'post.list' permission
    authorize_with_permission!('post.list')
  end

  def create
    authorize_with_permission!('post.create')
    # Create post...
  end

  def destroy
    authorize_admin!
    # Delete post...
  end
end
```

### Authorization Methods

- `authorize_with_role!(role_name, resource_type=nil, resource_id=nil)` - Require a role
- `authorize_with_permission!(permission_name, resource_type=nil, resource_id=nil)` - Require a permission
- `authorize_with_any_permission!(permissions, resource_type=nil, resource_id=nil)` - Require any of multiple permissions
- `authorize_with_all_permissions!(permissions, resource_type=nil, resource_id=nil)` - Require all permissions
- `authorize_admin!` - Require admin role

### Helper Methods in Views

```erb
<% if current_user_has_permission?('post.edit') %>
  <%= link_to 'Edit', edit_post_path(@post) %>
<% end %>

<% if current_user_admin? %>
  <%= link_to 'Admin Panel', admin_path %>
<% end %>
```

## Pundit Integration

Policies work seamlessly with RBAC:

```ruby
class PostPolicy < ApplicationPolicy
  def index?
    user.has_permission?('post.list')
  end

  def show?
    user.has_permission?('post.read')
  end

  def create?
    user.has_permission?('post.create')
  end

  def update?
    user.has_permission?('post.update')
  end

  def destroy?
    user.has_permission?('post.delete')
  end
end
```

Then authorize in your controller:

```ruby
class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)
    authorize @post
    @post.save
  end
end
```

## Global vs Resource-Scoped Permissions

### Global Permissions

Global permissions apply across the entire application:

```ruby
# Create global permission
permission = Permission.create!(
  name: 'dashboard.access',
  description: 'Access the dashboard'
  # resource_type and resource_id are nil
)

# Grant role with global permission
admin_role.grant_permission(permission)

# Check global permission
user.has_permission?('dashboard.access')
```

### Resource-Scoped Permissions

Resource-scoped permissions apply only to specific resources:

```ruby
# Create resource-scoped permission
permission = Permission.create!(
  name: 'edit',
  description: 'Edit this post',
  resource_type: 'Post',
  resource_id: post.id
)

# Grant and check with scope
editor_role.grant_permission(permission)
user.has_permission?('edit', 'Post', post.id)  # true
user.has_permission?('edit', 'Post', other_post.id)  # false
```

## Seeding Default Roles and Permissions

Use `Seeding::RbacService` to set up default roles and permissions:

```ruby
# In db/seeds.rb
Seeding::RbacService.seed_default_roles_and_permissions
```

This creates the following default roles:
- **admin** - Full system access
- **user** - Basic user access
- **manager** - Elevated permissions
- **moderator** - Content moderation
- **viewer** - Read-only access

And includes pre-configured permissions for each role.

## Database Schema

### Roles Table

```
id          - Primary key
name        - Role name (required)
description - Role description
resource_type - Optional resource type for scoped roles
resource_id - Optional resource ID for scoped roles
created_at
updated_at
```

### Permissions Table

```
id          - Primary key
name        - Permission name (required)
description - Permission description (required)
resource_type - Optional resource type for scoped permissions
resource_id - Optional resource ID for scoped permissions
created_at
updated_at
```

### Relationships

```
users (has many) ←→ user_roles (join table) ←→ roles (has many)
                                              ↓
                                        role_permissions (join table)
                                              ↓
                                        permissions
```

## Best Practices

1. **Use Permission Naming Conventions**: Use dot notation for permission names (e.g., `post.create`, `post.edit`, `user.delete`)

2. **Create Permissions First**: Create permissions before assigning them to roles

3. **Use Service for Operations**: Use `RbacService` for role and permission management instead of direct model manipulation

4. **Scope When Needed**: Use resource-scoped roles/permissions for fine-grained access control

5. **Check in Policies**: Always check permissions in Pundit policies, not just in controllers

6. **Meaningful Descriptions**: Always provide clear descriptions for roles and permissions

7. **Test Authorization**: Write specs for policies and authorization logic

## Examples

### Example 1: Simple Permission Check in Controller

```ruby
class DashboardController < ApplicationController
  def index
    authorize_with_permission!('dashboard.access')
    # Show dashboard
  end
end
```

### Example 2: Resource-Scoped Authorization

```ruby
class PostsController < ApplicationController
  before_action :set_post, only: [:edit, :update, :destroy]

  def edit
    authorize_with_permission!('edit', 'Post', @post.id)
    # Edit form
  end

  def update
    authorize_with_permission!('update', 'Post', @post.id)
    @post.update(post_params)
  end
end
```

### Example 3: Complex Permission Check

```ruby
class CommentsController < ApplicationController
  def moderate
    # User must have at least one moderation permission
    authorize_with_any_permission!(['comment.approve', 'comment.reject', 'comment.delete'])
    # Perform moderation
  end

  def publish
    # User must have both permissions
    authorize_with_all_permissions!(['comment.create', 'comment.publish'])
    # Publish comment
  end
end
```

### Example 4: Seeding Roles and Permissions

```ruby
# In db/seeds.rb or a rake task

# Create roles
editor_role = RbacService.find_or_create_role('editor', 'Content editor')
reviewer_role = RbacService.find_or_create_role('reviewer', 'Content reviewer')

# Create permissions
create_perm = RbacService.find_or_create_permission('post.create', 'Create posts')
edit_perm = RbacService.find_or_create_permission('post.edit', 'Edit posts')
publish_perm = RbacService.find_or_create_permission('post.publish', 'Publish posts')

# Grant permissions to roles
editor_role.grant_permission(create_perm)
editor_role.grant_permission(edit_perm)
reviewer_role.grant_permission(publish_perm)

# Assign roles to users
user = User.find_by(email_address: 'editor@example.com')
user.grant_role(editor_role)
```

### Example 5: Custom Policy with RBAC

```ruby
class PostPolicy < ApplicationPolicy
  def index?
    user.has_permission?('post.list')
  end

  def show?
    user.has_permission?('post.read') || owned_by_user?
  end

  def create?
    user.has_permission?('post.create')
  end

  def update?
    owned_by_user? && user.has_permission?('post.update')
  end

  def publish?
    user.has_permission?('post.publish')
  end

  def destroy?
    user.has_permission?('post.delete') || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.has_permission?('post.list')
        scope.all
      else
        scope.where(user_id: user.id)
      end
    end
  end

  private

  def owned_by_user?
    record.user_id == user.id
  end
end
```

## Troubleshooting

### User not getting expected permissions

Check that:
1. The role is assigned to the user: `user.has_role?('role_name')`
2. The permission is assigned to the role: `role.has_permission?('permission.name')`
3. Permission names match exactly (case-insensitive matching happens automatically)

### Resource-scoped permissions not working

Make sure:
1. Both `resource_type` and `resource_id` are specified when creating the permission
2. Both values match exactly when checking permissions
3. The resource type is a string (not a class)

### Performance issues

Use eager loading to prevent N+1 queries:

```ruby
users = User.includes(roles: :permissions).all

# This won't cause N+1 queries
users.each do |user|
  user.has_permission?('post.create')
end
```

## API Reference

See the inline documentation in the following files:
- `app/models/role.rb`
- `app/models/permission.rb`
- `app/models/user.rb`
- `app/services/rbac_service.rb`
- `app/controllers/concerns/authorization.rb`
