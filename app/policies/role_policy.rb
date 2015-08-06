class RolePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def permitted_attributes
    if user.admin?
      [:name, :description, permissions: [projects: [], approvals: [], memberships: []]]
    end
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
