# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  def index?
    user.has_any_permission?("roles.index", "roles.manage") || user.admin?
  end

  def show?
    user.has_any_permission?("roles.show", "roles.manage") || user.admin?
  end

  def create?
    user.has_any_permission?("roles.create", "roles.manage") || user.admin?
  end

  def new?
    create?
  end

  def update?
    user.has_any_permission?("roles.update", "roles.manage") || user.admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.has_any_permission?("roles.destroy", "roles.manage") || user.admin?
  end

  def assign_permissions?
    user.has_any_permission?("roles.assign_permissions", "roles.manage") || user.admin?
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
