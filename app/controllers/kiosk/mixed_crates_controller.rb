class Kiosk::MixedCratesController < ApplicationController
  skip_before_action :authenticate_member!

  def create
    @member = Member.find(params[:member_id])
    @crate = MixedCrate.find(params[:mixed_crate_id])

    unless @member.can_purchase?(@crate.price_cents)
      redirect_to kiosk_root_path, alert: "Saldo zu niedrig" and return
    end

    @crate.mixed_crate_items.each do |item|
      Transaction.create!(
        member: @member,
        product: item.product,
        amount_cents: -(item.product.price * item.quantity),
        kind: :drink_purchase,
        quantity: item.quantity,
        note: "#{item.quantity}x #{item.product.name} (#{@crate.name})"
      )
    end

    total_price_unit = @crate.mixed_crate_items.sum { |i| i.product.price_cents * i.quantity }
    discount = total_price_unit - @crate.price_cents
    if discount > 0
      Transaction.create!(
        member: @member,
        amount_cents: discount,
        kind: :expense_reimbursement,
        note: "Kastenrabatt #{crate.name}"
      )
    end

    redirect_to kiosk_root_path,
                notice: "#{@crate.name} für #{@member.display_name} gebucht"
  end
end