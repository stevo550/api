class OrderItemPolicy < ApplicationPolicy
  def index?
    true
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

  def retire_service?
    admin_or_related
  end

  def permitted_attributes
    if user.admin?
      [:uuid, :hourly_price, :monthly_price, :setup_price]
    end
  end

  private

  def admin_or_related
    user.admin? || user.project_ids.include?(record.project_id)
  end
end
