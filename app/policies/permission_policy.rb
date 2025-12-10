class PermissionPolicy < ApplicationPolicy
  def index?
    user.has_permission?('permission.list')
  end

  def show?
    user.has_permission?('permission.read')
  end

  def create?
    user.has_permission?('permission.create')
  end

  def update?
    user.has_permission?('permission.update')
  end

  def destroy?
    user.has_permission?('permission.delete')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_permission?('permission.list')
        scope.all
      else
        scope.none
      end
    end
  end
end
