class Kiosk::DrinksController < ApplicationController
  skip_before_action :authenticate_member!

  def index
    @members = Member.order(:display_name)
    @products = Product.active.order(:name)
    @mixed_crates = MixedCrate.active.includes(:mixed_crate_items)
    @selected_member = Member.find_by(id: params[:member_id])

    if @selected_member
      if params[:pin].present?
        @pin_verified = @selected_member.pin == params[:pin]
        flash.now[:alert] = "Falsche PIN" unless @pin_verified
      else
        @pin_verified = false
      end
    end
  end

  def create
    @member = Member.find(params[:member_id])
    @product = Product.find(params[:product_id])
    quantity = (params[:quantity] || 1).to_i
    amount_cents = if quantity > 1 && @product.has_crate?
                     @product.crate_price_cents
    else
                     @product.price_cents * quantity
    end

    unless @member.can_purchase?(amount_cents)
      redirect_to kiosk_root_path, alert: "Saldo zu niedrig (Limit: -50€)" and return
    end

    Transaction.create!(
      member: @member,
      product: @product,
      amount_cents: -amount_cents,
      kind: :drink_purchase,
      quantity: quantity,
      note: quantity > 1 ? "#{quantity} x #{@product.name} (Kasten)" : @product.name
    )

    redirect_to kiosk_root_path, notice: "#{quantity} x #{@product.name} für #{@member.display_name} gebucht"
  end
end
