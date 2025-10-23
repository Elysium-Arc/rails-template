# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def index?
    user.has_permission?('users.index') || user.has_role?('admin')
  end

  def show?
    user.has_permission?('users.show') || user.has_role?('admin') || record == user
  end

  def create?
    user.has_permission?('users.create') || user.has_role?('admin')
  end

  def update?
    user.has_permission?('users.update') || user.has_role?('admin') || record == user
  end

  def destroy?
    user.has_permission?('users.destroy') || user.has_role?('admin')
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?('admin') || user.has_permission?('users.index')
        scope.all
      else
        scope.where(id: user.id)
      end
    end
  end
end
