# frozen_string_literal: true

class RolePolicy < ApplicationPolicy
  def index?
    user.has_permission?("roles.index") || user.has_role?("admin")
  end

  def show?
    user.has_permission?("roles.show") || user.has_role?("admin")
  end

  def create?
    user.has_permission?("roles.create") || user.has_role?("admin")
  end

  def update?
    user.has_permission?("roles.update") || user.has_role?("admin")
  end

  def destroy?
    user.has_permission?("roles.destroy") || user.has_role?("admin")
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?("admin")
        scope.all
      else
        scope.none
      end
    end
  end
end
