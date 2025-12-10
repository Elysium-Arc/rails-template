# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  def index?
    user.has_permission?('role.list')
  end

  def show?
    user.has_permission?('role.read')
  end

  def create?
    user.has_permission?('role.create')
  end

  def update?
    user.has_permission?('role.update')
  end

  def destroy?
    user.has_permission?('role.delete')
  end

  def add_permission?
    user.has_permission?('role.manage_permissions')
  end

  def remove_permission?
    user.has_permission?('role.manage_permissions')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_permission?('role.list')
        scope.all
      else
        scope.none
      end
    end
  end
end
