# RBAC Implementation Guide

This document provides a comprehensive guide to the Role-Based Access Control (RBAC) system added to this Rails template.

## Overview

The RBAC system allows you to control access to resources based on user roles and permissions. It integrates seamlessly with Pundit for authorization and provides a complete UI for managing roles and permissions.

## Database Schema

The RBAC system uses four main tables:

### Roles Table
- `id`: Primary key
- `name`: Unique role name (e.g., "admin", "moderator")
- `description`: Human-readable description
- `resource_type`: Optional - for resource-specific roles
- `resource_id`: Optional - for resource-specific roles
- `created_at`, `updated_at`: Timestamps

### Permissions Table
- `id`: Primary key
- `name`: Unique permission name (e.g., "users.create")
- `description`: Human-readable description (required)
- `resource_type`: Optional - for resource-specific permissions
- `resource_id`: Optional - for resource-specific permissions
- `created_at`, `updated_at`: Timestamps

### UserRoles Table (Join Table)
- `id`: Primary key
- `user_id`: Foreign key to users
- `role_id`: Foreign key to roles
- `created_at`, `updated_at`: Timestamps
- Unique constraint on `[user_id, role_id]`

### RolePermissions Table (Join Table)
- `id`: Primary key
- `role_id`: Foreign key to roles
- `permission_id`: Foreign key to permissions
- `created_at`, `updated_at`: Timestamps
- Unique constraint on `[role_id, permission_id]`

## Models

### Role Model (`app/models/role.rb`)

**Associations:**
- `has_many :user_roles`
- `has_many :users, through: :user_roles`
- `has_many :role_permissions`
- `has_many :permissions, through: :role_permissions`

**Methods:**
- `has_permission?(permission_name)` - Check if role has a specific permission
- `add_permission(permission)` - Add a permission to the role
- `remove_permission(permission)` - Remove a permission from the role
- `global?` - Check if role is global (not resource-specific)

**Scopes:**
- `Role.global` - Returns all global roles
- `Role.resource_specific(type, id)` - Returns resource-specific roles

### Permission Model (`app/models/permission.rb`)

**Associations:**
- `has_many :role_permissions`
- `has_many :roles, through: :role_permissions`

**Methods:**
- `global?` - Check if permission is global (not resource-specific)

**Scopes:**
- `Permission.global` - Returns all global permissions
- `Permission.resource_specific(type, id)` - Returns resource-specific permissions

### User Model (Updated `app/models/user.rb`)

**New Associations:**
- `has_many :user_roles`
- `has_many :roles, through: :user_roles`

**New Methods:**
- `has_role?(role_name)` - Check if user has a specific role
- `has_any_role?(*role_names)` - Check if user has any of the specified roles
- `has_permission?(permission_name)` - Check if user has a specific permission (through roles)
- `add_role(role)` - Assign a role to the user
- `remove_role(role)` - Remove a role from the user
- `permission_names` - Get array of all permission names user has

## Controllers

### RolesController (`app/controllers/roles_controller.rb`)
Full CRUD operations for roles with authorization checks and Turbo Stream support.

**Actions:**
- `index` - List all roles (with filtering and pagination)
- `show` - Display role details
- `new` - Form to create new role
- `create` - Create a new role
- `edit` - Form to edit role
- `update` - Update role
- `destroy` - Delete role

### PermissionsController (`app/controllers/permissions_controller.rb`)
Full CRUD operations for permissions with authorization checks and Turbo Stream support.

**Actions:**
- `index` - List all permissions (with filtering and pagination)
- `show` - Display permission details
- `new` - Form to create new permission
- `create` - Create a new permission
- `edit` - Form to edit permission
- `update` - Update permission
- `destroy` - Delete permission

## Policies

### RolePolicy (`app/policies/role_policy.rb`)
Authorizes role management actions. Only admins can manage roles by default.

### PermissionPolicy (`app/policies/permission_policy.rb`)
Authorizes permission management actions. Only admins can manage permissions by default.

### UserPolicy (`app/policies/user_policy.rb`)
Updated to use role-based authorization for user management.

## Views

### Roles Views (`app/views/roles/`)
- `index.html.erb` - DataTable with filters for listing roles
- `show.html.erb` - Display role details, permissions, and users
- `new.html.erb` - Form for creating new role
- `edit.html.erb` - Form for editing role
- `_table.html.erb` - Table component for roles (used in Turbo Streams)

### Permissions Views (`app/views/permissions/`)
- `index.html.erb` - DataTable with filters for listing permissions
- `show.html.erb` - Display permission details and roles
- `new.html.erb` - Form for creating new permission
- `edit.html.erb` - Form for editing permission
- `_table.html.erb` - Table component for permissions (used in Turbo Streams)

## Seeding

The `db/seeds.rb` file creates:

### Default Permissions (15 total)
- **User Management**: users.index, users.show, users.create, users.update, users.destroy
- **Role Management**: roles.index, roles.show, roles.create, roles.update, roles.destroy
- **Permission Management**: permissions.index, permissions.show, permissions.create, permissions.update, permissions.destroy

### Default Roles (3 total)
1. **Admin**: Has all permissions
2. **User**: Has users.show and users.update (can view and update their own profile)
3. **Moderator**: Has users.index, users.show, users.create, users.update

## Testing

### Model Specs
- `spec/models/role_spec.rb` - Tests for Role model
- `spec/models/permission_spec.rb` - Tests for Permission model
- `spec/models/user_role_spec.rb` - Tests for UserRole join model
- `spec/models/role_permission_spec.rb` - Tests for RolePermission join model
- Updated `spec/models/user_spec.rb` - Tests for role methods on User

### Policy Specs
- `spec/policies/role_policy_spec.rb` - Tests for RolePolicy
- `spec/policies/permission_policy_spec.rb` - Tests for PermissionPolicy
- `spec/policies/user_policy_spec.rb` - Tests for UserPolicy

### Factories
- `spec/factories/roles.rb` - Factory for creating test roles
- `spec/factories/permissions.rb` - Factory for creating test permissions
- `spec/factories/user_roles.rb` - Factory for creating user-role associations
- `spec/factories/role_permissions.rb` - Factory for creating role-permission associations
- Updated `spec/factories/users.rb` - Added role traits

## Usage Examples

### Creating Roles and Permissions

```ruby
# Create a role
role = Role.create!(
  name: 'content_editor',
  description: 'Can create and edit content'
)

# Create permissions
view_content = Permission.create!(
  name: 'content.view',
  description: 'View content'
)

edit_content = Permission.create!(
  name: 'content.edit',
  description: 'Edit content'
)

# Assign permissions to role
role.permissions << view_content
role.add_permission(edit_content)
```

### Assigning Roles to Users

```ruby
user = User.find_by(email_address: 'user@example.com')
editor_role = Role.find_by(name: 'content_editor')

# Assign role
user.add_role(editor_role)
# or
user.roles << editor_role

# Check if user has role
user.has_role?('content_editor') # => true

# Check if user has permission
user.has_permission?('content.edit') # => true
```

### Using in Controllers

```ruby
class ArticlesController < ApplicationController
  before_action :set_article, only: [:edit, :update, :destroy]
  
  def index
    authorize Article
    @articles = policy_scope(Article)
  end
  
  def edit
    authorize @article
  end
  
  private
  
  def set_article
    @article = Article.find(params[:id])
  end
end
```

### Using in Policies

```ruby
class ArticlePolicy < ApplicationPolicy
  def edit?
    user.has_permission?('content.edit') || 
    user.has_role?('admin') ||
    record.author == user
  end
  
  def destroy?
    user.has_role?('admin') || record.author == user
  end
  
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?('admin')
        scope.all
      else
        scope.where(author: user)
      end
    end
  end
end
```

### Using in Views

```erb
<% if current_user.has_role?('admin') %>
  <%= link_to 'Manage Roles', roles_path, class: 'btn btn-primary' %>
<% end %>

<% if current_user.has_permission?('content.edit') %>
  <%= link_to 'Edit Article', edit_article_path(@article) %>
<% end %>
```

### Resource-Specific Roles

```ruby
# Create a project-specific role
project = Project.find(1)
project_admin = Role.create!(
  name: 'admin',
  description: 'Administrator for this project',
  resource_type: 'Project',
  resource_id: project.id
)

# Find resource-specific roles
project_roles = Role.resource_specific('Project', project.id)
```

## Navigation

The sidebar component automatically shows role and permission management links to users who have the appropriate permissions:

- **Roles link**: Shown to users with 'admin' role or 'roles.index' permission
- **Permissions link**: Shown to users with 'admin' role or 'permissions.index' permission

## Best Practices

1. **Permission Naming**: Use a consistent naming convention: `resource.action` (e.g., `users.create`, `articles.update`)

2. **Role Hierarchy**: Create roles with increasing levels of access:
   - `user` → Basic access
   - `moderator` → Limited admin access
   - `admin` → Full access

3. **Testing**: Always test authorization in controllers and policies:
   ```ruby
   it 'allows admin to create users' do
     admin = create(:user, :admin)
     expect(UserPolicy.new(admin, User).create?).to be true
   end
   ```

4. **Seed Data**: Include default roles and permissions in your seeds for consistent setup across environments.

5. **Auditing**: All role and permission changes are automatically audited through the `audited` gem.

## Troubleshooting

### User doesn't have expected permissions

Check:
1. Does the user have the role assigned? `user.roles.pluck(:name)`
2. Does the role have the permission? `role.permissions.pluck(:name)`
3. Are the role-permission associations correct? `RolePermission.where(role: role)`

### Authorization failing in controller

Ensure:
1. The controller includes `Pundit::Authorization`
2. You're calling `authorize` before the action
3. The policy exists and has the correct method (e.g., `index?`, `create?`)

### Seeding fails

Check:
1. Run migrations first: `rails db:migrate`
2. Check for duplicate names in roles/permissions
3. Verify foreign key constraints are satisfied

## Customization

### Adding New Permissions

1. Add permission in seeds:
   ```ruby
   Permission.create!(
     name: 'reports.view',
     description: 'View reports'
   )
   ```

2. Assign to appropriate roles
3. Use in policies and controllers

### Creating Custom Roles

1. Define role in seeds or through UI
2. Assign appropriate permissions
3. Use `has_role?` or `has_permission?` in your code

### Resource-Specific Authorization

For fine-grained control, use resource-specific roles:

```ruby
# Create resource-specific role
team_admin = Role.create!(
  name: 'admin',
  resource_type: 'Team',
  resource_id: team.id,
  description: 'Team administrator'
)

# Check in policy
def update?
  user.has_role?('admin') ||
  user.roles.exists?(
    name: 'admin',
    resource_type: 'Team',
    resource_id: record.team_id
  )
end
```

## Migration Guide

If you're adding RBAC to an existing application:

1. Run the migrations: `rails db:migrate`
2. Run the seeds: `rails db:seed`
3. Assign roles to existing users:
   ```ruby
   admin_role = Role.find_by(name: 'admin')
   User.where(admin: true).find_each do |user|
     user.add_role(admin_role)
   end
   ```
4. Update controllers to use `authorize` and `policy_scope`
5. Update policies to use role-based checks
6. Test thoroughly!

## Additional Resources

- [Pundit Documentation](https://github.com/varvet/pundit)
- [Rails Authorization](https://guides.rubyonrails.org/action_controller_overview.html#authorization)
- Application README.md for more usage examples
