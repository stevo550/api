class ProjectQuestionPolicy < ApplicationPolicy
  def index?
    true
  end

  def create?
    user.admin?
  end

  def show?
    true
  end

  def new?
    true
  end

  def update?
    true
  end

  def destroy?
    user.admin?
  end

  def sort?
    user.admin?
  end

  def permitted_attributes
    if user.admin?
      [:id, :question, :field_type, :help_text, :position, :required, options: [:option, :position, exclude: [], include: []]]
    end
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
