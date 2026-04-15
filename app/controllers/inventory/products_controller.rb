class Inventory::ProductsController < Inventory::BaseController
  def index
    @products = Product.order(:name)
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to inventory_products_path, notice: "Produkt angelegt"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      redirect_to inventory_products_path, notice: "Produkt aktualisiert"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :price_cents, :active)
  end
end
