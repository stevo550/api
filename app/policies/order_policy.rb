class OrderPolicy < ApplicationPolicy
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

  def items?
    admin_or_related
  end

  def permitted_attributes
    if admin_or_related
      [:id, :staff_id, :total, :bundle_id, options: [], order_items_attributes: [:id, :project_id, :product_id, :cloud_id]]
    end
  end

  private

  def admin_or_related
    user.admin? || user.project_ids.include?(record.project_id)
  end
end
