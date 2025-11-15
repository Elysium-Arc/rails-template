# Role-Based Access Control (RBAC) System

This Rails application includes a fully-featured RBAC system that provides fine-grained access control for users, resources, and actions.

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Models](#models)
- [Usage](#usage)
- [Policies](#policies)
- [Controllers](#controllers)
- [Seeding](#seeding)
- [Testing](#testing)
- [Examples](#examples)

## Overview

The RBAC system provides:

- **Roles**: Groups of permissions that can be assigned to users
- **Permissions**: Fine-grained control over specific actions
- **User-Role Assignments**: Many-to-many relationship between users and roles
- **Role-Permission Assignments**: Many-to-many relationship between roles and permissions
- **Resource-Scoped Permissions**: Support for global and resource-specific permissions
- **Pundit Integration**: Seamless integration with Pundit policies for authorization
- **Performance Optimizations**: Caching for permission checks

## Architecture

### Database Schema

```
┌─────────┐       ┌────────────┐       ┌──────┐       ┌─────────────────┐       ┌─────────────┐
│  User   │──────▶│ user_roles │◀──────│ Role │──────▶│ role_permissions│◀──────│ Permission  │
└─────────┘       └────────────┘       └──────┘       └─────────────────┘       └─────────────┘
```

### Key Features

1. **Global Roles**: Roles not tied to any specific resource (e.g., `super_admin`, `admin`)
2. **Scoped Roles**: Roles tied to specific resources (e.g., `manager` of Organization #1)
3. **Permission Caching**: User permissions are cached for performance
4. **Auditing**: All RBAC changes are audited via the `audited` gem

## Models

### Role

**app/models/role.rb**

```ruby
class Role < ApplicationRecord
  has_many :permissions, through: :role_permissions
  has_many :users, through: :user_roles
  belongs_to :resource, polymorphic: true, optional: true

  validates :name, presence: true, uniqueness: { scope: [:resource_type, :resource_id] }
end
```

**Key Methods:**
- `has_permission?(permission_name, resource = nil)` - Check if role has a permission
- `global?` - Check if role is global
- `scoped?` - Check if role is scoped to a resource
- `display_name` - Human-readable name
- `full_display_name` - Name with resource info if scoped

### Permission

**app/models/permission.rb**

```ruby
class Permission < ApplicationRecord
  has_many :roles, through: :role_permissions
  belongs_to :resource, polymorphic: true, optional: true

  validates :name, presence: true, uniqueness: { scope: [:resource_type, :resource_id] }
  validates :description, presence: true
end
```

**Key Methods:**
- `global?` - Check if permission is global
- `scoped?` - Check if permission is scoped
- `display_name` - Human-readable name
- `action_and_subject` - Extract action and subject from name

### User (RBAC Extensions)

**app/models/user.rb**

```ruby
class User < ApplicationRecord
  has_many :roles, through: :user_roles
  has_many :permissions, through: :role_permissions
end
```

**Key Methods:**
- `add_role(role_name, resource = nil)` - Assign a role to the user
- `remove_role(role_name, resource = nil)` - Remove a role from the user
- `has_role?(role_name, resource = nil)` - Check if user has a role
- `has_any_role?(*role_names)` - Check if user has any of the given roles
- `has_all_roles?(*role_names)` - Check if user has all of the given roles
- `has_permission?(permission_name, resource = nil)` - Check if user has a permission
- `has_any_permission?(*permission_names)` - Check if user has any permissions
- `has_all_permissions?(*permission_names)` - Check if user has all permissions
- `permission_names` - Get all permission names for the user
- `role_names` - Get all role names for the user
- `admin?` - Check if user is an admin
- `super_admin?` - Check if user is a super admin

## Usage

### Assigning Roles to Users

```ruby
user = User.find(1)

# Assign a global role
user.add_role("admin")

# Assign a scoped role
organization = Organization.find(1)
user.add_role("manager", organization)

# Remove a role
user.remove_role("admin")
```

### Checking Permissions

```ruby
# Check if user has a specific role
user.has_role?("admin")  # => true/false

# Check if user has any of the given roles
user.has_any_role?("admin", "super_admin")  # => true/false

# Check if user has a specific permission
user.has_permission?("users.create")  # => true/false

# Check if user has any of the given permissions
user.has_any_permission?("users.create", "users.update")  # => true/false
```

### In Controllers

```ruby
class ArticlesController < ApplicationController
  def index
    authorize Article
    # Only users with 'articles.index' permission or admin role can access
  end

  def create
    @article = Article.new(article_params)
    authorize @article
    # Pundit policy will check permissions
  end

  # Using role-based authorization
  before_action :require_admin, only: [:dangerous_action]

  private

  def require_admin
    authorize_role!("admin", "super_admin")
  end
end
```

### In Views

```erb
<% if current_user_has_permission?("users.create") %>
  <%= link_to "Create User", new_user_path %>
<% end %>

<% if current_user_has_role?("admin") %>
  <%= link_to "Admin Panel", admin_path %>
<% end %>
```

## Policies

### Example: UserPolicy

**app/policies/user_policy.rb**

```ruby
class UserPolicy < ApplicationPolicy
  def index?
    user.has_any_permission?("users.index", "users.manage") || user.admin?
  end

  def show?
    record.id == user.id || user.has_any_permission?("users.show", "users.manage") || user.admin?
  end

  def create?
    user.has_any_permission?("users.create", "users.manage") || user.admin?
  end

  def update?
    record.id == user.id || user.has_any_permission?("users.update", "users.manage") || user.admin?
  end

  def destroy?
    record.id != user.id && (user.has_any_permission?("users.destroy", "users.manage") || user.admin?)
  end
end
```

## Controllers

### RolesController

Manages roles in the system:
- `GET /roles` - List all roles
- `GET /roles/:id` - Show role details
- `POST /roles` - Create a new role
- `PATCH /roles/:id` - Update a role
- `DELETE /roles/:id` - Delete a role
- `POST /roles/:id/assign_permissions` - Assign permissions to a role

### PermissionsController

Manages permissions in the system:
- `GET /permissions` - List all permissions
- `GET /permissions/:id` - Show permission details
- `POST /permissions` - Create a new permission
- `PATCH /permissions/:id` - Update a permission
- `DELETE /permissions/:id` - Delete a permission

### User Role Assignment

Routes for assigning roles to users:
- `POST /users/:id/assign_roles` - Assign roles to a user
- `DELETE /users/:id/remove_role` - Remove a role from a user

## Seeding

The RBAC system comes with a comprehensive seeder that creates default roles and permissions.

### Default Roles

1. **super_admin** - Full system access, can manage permissions
2. **admin** - Full access to manage users, roles, and most features
3. **manager** - View and manage users and own resources
4. **user** - Basic access to view and manage own data
5. **viewer** - Read-only access to permitted resources

### Default Permissions

The seeder creates permissions for:
- User management (`users.index`, `users.create`, `users.update`, etc.)
- Role management (`roles.index`, `roles.create`, etc.)
- Permission management (`permissions.index`, `permissions.create`, etc.)
- Dashboard access (`dashboard.view`, `dashboard.analytics`)
- Audit logs (`audits.view`, `audits.export`)
- Settings (`settings.view`, `settings.update`)

### Running Seeds

```bash
./bin/rails db:seed
```

The seeder automatically:
1. Creates all permissions
2. Creates all roles
3. Assigns permissions to roles based on predefined mappings
4. Assigns roles to test users in development

## Testing

### Model Tests

```ruby
RSpec.describe User, type: :model do
  describe '#add_role' do
    it 'adds a role to the user' do
      user = create(:user)
      role = create(:role, name: 'admin')

      expect { user.add_role('admin') }.to change { user.roles.count }.by(1)
    end
  end

  describe '#has_permission?' do
    it 'returns true when user has the permission through a role' do
      user = create(:user)
      role = create(:role, name: 'admin')
      permission = create(:permission, name: 'users.create')
      create(:role_permission, role: role, permission: permission)

      user.add_role('admin')

      expect(user.has_permission?('users.create')).to be true
    end
  end
end
```

### Policy Tests

```ruby
RSpec.describe UserPolicy, type: :policy do
  subject { described_class.new(user, record) }

  context 'for an admin user' do
    let(:user) { create(:user, :admin) }
    let(:record) { create(:user) }

    it { should permit_action(:index) }
    it { should permit_action(:show) }
    it { should permit_action(:create) }
    it { should permit_action(:update) }
    it { should permit_action(:destroy) }
  end

  context 'for a regular user' do
    let(:user) { create(:user) }
    let(:record) { create(:user) }

    it { should_not permit_action(:index) }
    it { should_not permit_action(:create) }
  end
end
```

### Factory Bot Factories

```ruby
FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
    description { "Description for #{name}" }

    trait :admin do
      name { "admin" }
    end

    trait :with_permissions do
      after(:create) do |role|
        create_list(:permission, 3, roles: [role])
      end
    end
  end

  factory :permission do
    sequence(:name) { |n| "permission_#{n}" }
    description { "Description for #{name}" }

    trait :users_create do
      name { "users.create" }
    end
  end
end
```

## Examples

### Creating a Custom Permission

```ruby
# Create a global permission
Permission.create!(
  name: "articles.publish",
  description: "Publish articles to the website"
)

# Create a resource-scoped permission
blog = Blog.find(1)
Permission.create!(
  name: "articles.publish",
  description: "Publish articles to this blog",
  resource: blog
)
```

### Creating a Custom Role

```ruby
# Create a global role
role = Role.create!(
  name: "content_editor",
  description: "Can edit and publish content"
)

# Assign permissions to the role
role.permissions << Permission.find_by(name: "articles.create")
role.permissions << Permission.find_by(name: "articles.update")
role.permissions << Permission.find_by(name: "articles.publish")
```

### Complex Permission Checks

```ruby
# Check multiple permissions
if current_user.has_all_permissions?("articles.create", "articles.publish")
  # User can both create and publish
end

# Check for admin or specific permission
if current_user.admin? || current_user.has_permission?("articles.moderate")
  # User can moderate articles
end

# Scoped permission check
article = Article.find(1)
if current_user.has_permission?("articles.edit", article)
  # User can edit this specific article
end
```

### Authorization in Controllers

```ruby
class ArticlesController < ApplicationController
  def publish
    @article = Article.find(params[:id])
    authorize @article, :publish?

    # If user doesn't have permission, Pundit will raise NotAuthorizedError
    @article.publish!

    redirect_to @article, notice: "Article published successfully"
  end

  private

  # In ArticlePolicy
  def publish?
    user.has_any_permission?("articles.publish", "articles.manage") || user.admin?
  end
end
```

## Best Practices

1. **Use Descriptive Permission Names**: Follow the pattern `resource.action` (e.g., `users.create`, `articles.publish`)

2. **Keep Roles Focused**: Each role should represent a specific set of responsibilities

3. **Leverage Inheritance**: Use the `admin?` and `super_admin?` helpers for broad access checks

4. **Cache Wisely**: The system caches permissions for performance, but be aware of cache invalidation

5. **Test Thoroughly**: Always test authorization logic with both positive and negative cases

6. **Audit Changes**: All role and permission changes are automatically audited

7. **Use Policies**: Encapsulate authorization logic in Pundit policies rather than controllers

8. **Scope Resources**: Use policy scopes to restrict resource access at the query level

## Troubleshooting

### Permission not working after assignment

Clear the cache:
```ruby
Rails.cache.delete("user_#{user.id}_permissions")
Rails.cache.delete("user_#{user.id}_permission_names")
```

### Role assignment not persisting

Check validations and ensure the role exists:
```ruby
role = Role.find_by(name: 'admin')
# Make sure role exists before assigning
```

### Performance issues with permission checks

Ensure you're using the cached versions and consider eager loading:
```ruby
users = User.includes(roles: :permissions).all
```
