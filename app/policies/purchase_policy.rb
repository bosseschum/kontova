class PurchasePolicy < ApplicationPolicy
  def create?
    user.inventory_manager?
  end

  def index?
    user.inventory_manager?
  end
end
