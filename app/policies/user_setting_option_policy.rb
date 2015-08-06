class UserSettingOptionPolicy < ApplicationPolicy
  def index?
    admin_or_related
  end

  def create?
    admin_or_related
  end

  def show?
    admin_or_related
  end

  def new?
    admin_or_related
  end

  def update?
    admin_or_related
  end

  def destroy?
    admin_or_related
  end

  def permitted_attributes
    if admin_or_related
      [:label, :field_type, :help_text, :options, :required]
    end
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

  private

  def admin_or_related
    user.admin?
  end
end
