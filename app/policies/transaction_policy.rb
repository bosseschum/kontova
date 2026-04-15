class TransactionPolicy < ApplicationPolicy
  def create?
    user.treasurer?
  end

  def index?
    user.treasurer?
  end
end
