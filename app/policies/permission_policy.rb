# frozen_string_literal: true

class PermissionPolicy < ApplicationPolicy
  def index?
    user.has_any_permission?("permissions.index", "permissions.manage") || user.admin?
  end

  def show?
    user.has_any_permission?("permissions.show", "permissions.manage") || user.admin?
  end

  def create?
    user.has_any_permission?("permissions.create", "permissions.manage") || user.super_admin?
  end

  def new?
    create?
  end

  def update?
    user.has_any_permission?("permissions.update", "permissions.manage") || user.super_admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.has_any_permission?("permissions.destroy", "permissions.manage") || user.super_admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.none
      end
    end
  end
end
