class Inventory::InventoryCountsController < Inventory::BaseController
  def index
    @products = Product.active.order(:name)
  end

  def new
    @inventory_count = InventoryCount.new
    @products = Product.active.order(:name)
  end

  def create
    @inventory_count = InventoryCount.new(
      count_params.merge(member: current_member, counted_on: Date.today)
    )
    if inventory_count.save
      redirect_to inventory_inventory_counts_path, notice: "Inventur gespeichert"
    else
      @products = Product.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def count_params
    params.require(:inventory_count).permit(:product_id, :actual_quantity, :note)
  end
end
