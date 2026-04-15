class ProductPolicy < ApplicationPolicy
  def create?
    user.inventory_manager?
  end

  def update?
    user.inventory_manager?
  end

  def destroy?
    user.inventory_manager?
  end

  def index?
    user.inventory_manager? || user.treasurer?
  end
end
