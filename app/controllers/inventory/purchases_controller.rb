class Inventory::PurchasesController < Inventory::BaseController
  def index
    @purchases = Purchase.includes(:product, :member).order(purchased_on: :desc)
  end

  def new
    @purchase = Purchase.new
    @products = Product.active.order(:name)
  end

  def create
    @purchase = Purchase.new(purchase_params.merge(member: current_member))
    if @purchase.save
      redirect_to inventory_purchases_path, notice: "Einkauf erfasst"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def purchase_params
    params.require(:purchase).permit(
      :product_id, :quantity, :price_per_unit_cents, :purchased_on, :note
    )
  end
end
