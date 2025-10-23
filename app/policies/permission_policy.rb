# frozen_string_literal: true

class PermissionPolicy < ApplicationPolicy
  def index?
    user.has_permission?('permissions.index') || user.has_role?('admin')
  end

  def show?
    user.has_permission?('permissions.show') || user.has_role?('admin')
  end

  def create?
    user.has_permission?('permissions.create') || user.has_role?('admin')
  end

  def update?
    user.has_permission?('permissions.update') || user.has_role?('admin')
  end

  def destroy?
    user.has_permission?('permissions.destroy') || user.has_role?('admin')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?('admin')
        scope.all
      else
        scope.none
      end
    end
  end
end
