class ProductPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def new?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def permitted_attributes
    if user.admin?
      [:name, :description, :img, :active, :hourly_price, :monthly_price, :setup_price, :product_type, provisioning_answers: [], tags: []]
    end
  end
end
