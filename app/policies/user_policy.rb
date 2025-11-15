# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.has_any_permission?("users.index", "users.manage") || user.admin?
  end

  def show?
    # Users can view their own profile or have permission
    record.id == user.id || user.has_any_permission?("users.show", "users.manage") || user.admin?
  end

  def create?
    user.has_any_permission?("users.create", "users.manage") || user.admin?
  end

  def new?
    create?
  end

  def update?
    # Users can update their own profile or have permission
    record.id == user.id || user.has_any_permission?("users.update", "users.manage") || user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    # Users cannot delete themselves
    record.id != user.id && (user.has_any_permission?("users.destroy", "users.manage") || user.admin?)
  end

  def assign_roles?
    user.has_any_permission?("users.assign_roles", "users.manage") || user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_any_permission?("users.index", "users.manage") || user.admin?
        scope.all
      else
        # Users can only see themselves
        scope.where(id: user.id)
      end
    end
  end
end
