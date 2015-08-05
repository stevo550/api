class MotdPolicy < ApplicationPolicy
  def index?
    false
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
      [:message, :staff_id]
    end
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
