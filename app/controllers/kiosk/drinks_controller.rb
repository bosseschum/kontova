class Kiosk::DrinksController < ApplicationController
  skip_before_action :authenticate_member!

  def index
    @members = Member.order(:display_name)
    @products = Product.active.order(:name)
    @selected_member = Member.find_by(id: params[:member_id])
  end

  def create
    @member = Member.find(params[:member_id])
    @product = Product.find(params[:product_id])
    amount_cents = @product.price_cents

    unless @member.can_purchase?(amount_cents)
      redirect_to kiosk_root_path, alert: "Saldo zu niedrig (Limit: -50€)" and return
    end

    Transaction.create!(
      member: @member,
      product: @product,
      amount_cents: -amount_cents,
      kind: :drink_purchase,
      quantity: 1
    )

    redirect_to kiosk_root_path, notice: "#{@product.name} für #{@member.display_name} gebucht"
  end
end
