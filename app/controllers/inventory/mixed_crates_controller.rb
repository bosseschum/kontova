class Inventory::MixedCratesController < Inventory::BaseController
  def index
    @mixed_crates = MixedCrate.includes(:mixed_crate_items, :products).order(:name)
  end

  def new
    @mixed_crate = MixedCrate.new
    @products = Product.active.order(:name)
  end

  def create
    @mixed_crate = MixedCrate.new(crate_params)
    if @mixed_crate.save
      save_items
      redirect_to inventory_mixed_crates_path, notice: "Kasten angelegt"
    else
      @products = Product.active.order(:name)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def crate_params
    params.require(:mixed_crate).permit(:name, :price_cents, :active)
  end

  def save_items
    params[:items].each do |product_id, quantity|
      next if quantity.to_i == 0
      @mixed_crate.mixed_crate_items.create!(
        product_id: product_id,
        quantity: quantity.to_i,
      )
    end
  end
end