class Inventory::DashboardController < Inventory::BaseController
  def index
    @products = Product.active.order(:name)
  end
end
