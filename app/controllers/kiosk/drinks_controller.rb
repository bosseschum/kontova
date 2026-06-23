class Kiosk::DrinksController < ApplicationController
  skip_before_action :authenticate_member!

  def index
    @organization = current_organization
    @products = current_organization.products.active.order(:name)

    if params[:pin].present?
      membership = current_organization.organization_memberships.find_by!(pin: params[:pin])
      @selected_member = membership&.member
      @selected_guest = current_organization.guest_accesses.active.find_by!(pin: params[:pin])
      @purchaser = @selected_member || @selected_guest
      @selected_membership = membership
      @pin_verified = @purchaser.present?
      flash.now[:alert] = "Unbekannte PIN" unless @pin_verified
    end

    if @selected_member && @pin_verified
      @cart  = session[:cart] ||= {}
      @cart_items = @cart.map do |product_id, quantity|
        { product: current_organization.products.find(product_id), quantity: quantity }
      end
      @total_quantity = @cart_items.sum { |i| i[:quantity] }
      @is_mixed_crate = @total_quantity == CRATE_SIZE
      @cart_total = if @is_mixed_crate
                      CRATE_PRICE_CENTS
      else
                      @cart_items.sum { |i| i[:product].price_cents * i[:quantity] }
      end
      @cart_total = @cart_items.sum do |i|
        is_crate = i[:product].has_crate? && i[:quantity] == i[:product].crate_size
        is_crate ? i[:product].crate_price_cents : i[:product].price_cents * i[:quantity]
      end
    end
  end

  def add_to_cart
    session[:cart] ||= {}
    product_id = params[:product_id].to_s
    quantity = params[:quantity].to_i
    session[:cart][product_id] = (session[:cart][product_id] || 0) + quantity
    redirect_to kiosk_root_path(pin: params[:pin])
  end

  def remove_from_cart
    session[:cart] ||= {}
    session[:cart].delete(params[:product_id]).to_s
    redirect_to kiosk_root_path(pin: params[:pin])
  end

  def checkout
    membership = current_organization.organization_memberships.find_by!(pin: params[:pin])
    @member = membership.member
    cart    = session[:cart] || {}
    sponsored = params[:sponsored] == "1"

    if cart.empty?
      redirect_to kiosk_root_path(pin: params[:pin]),
                  alert: "Warenkorb ist leer" and return
    end

    total_quantity = cart.values.sum
    is_mixed_crate = total_quantity == CRATE_SIZE

    total = if is_mixed_crate
              CRATE_PRICE_CENTS
    else
              cart.sum { |pid, qty| current_organization.products.find(pid).price_cents * qty }
    end

    unless @member.can_purchase?(total)
      redirect_to kiosk_root_path(pin: params[:pin]),
                  alert: "Saldo zu niedrig (Limit: -50€)" and return
    end

    single_purchase = cart.sum { |pid, qty| current_organization.products.find(pid).price_cents * qty }

    # 1. Keep track of how much total money we have allocated so far
    allocated_total = 0
    items_processed = 0

    cart.each do |product_id, quantity|
      product = current_organization.products.find(product_id)
      items_processed += quantity

      actual_amount = if !sponsored && is_mixed_crate && single_purchase > CRATE_PRICE_CENTS
                        if items_processed == total_quantity
                          # 2. The last item absorbs any fraction-of-a-cent rounding errors
                          CRATE_PRICE_CENTS - allocated_total
                        else
                          # Proportional split strictly using integer math
                          item_share = (CRATE_PRICE_CENTS.to_f * quantity / total_quantity).round
                          allocated_total += item_share
                          item_share
                        end
      else
                        product.price_cents * quantity
      end

      Transaction.create!(
        member: @member,
        organization: current_organization,
        product: product,
        amount_cents: sponsored ? 0 : -actual_amount,
        original_amount_cents: product.price_cents * quantity,
        kind: :drink_purchase,
        quantity: quantity,
        sponsored: sponsored,
        note: "#{quantity} x #{product.name}#{is_mixed_crate ? " (Mischkasten-Anteil)" : ""}#{sponsored ? " (Veranstaltung/Couleur)" : ""}"
      )
    end

    session[:cart] = {}
    redirect_to kiosk_root_path,
                notice: "Einkauf abgeschlossen - #{format("%.2f", total / 100.0)}€ gebucht!#{sponsored ? " (Veranstaltung/Couleur)" : ""}"
  end

  def clear_cart
    session[:cart] = {}
    redirect_to kiosk_root_path(pin: params[:pin])
  end

  def create
    membership = current_organization.organization_memberships.find(params[:member_id])
    @member = membership.member
    @product = current_organization.products.find(params[:product_id])
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
      organization: current_organization,
      product: @product,
      amount_cents: -amount_cents,
      kind: :drink_purchase,
      quantity: quantity,
      note: quantity > 1 ? "#{quantity} x #{@product.name} (Kasten)" : @product.name
    )

    redirect_to kiosk_root_path, notice: "#{quantity} x #{@product.name} für #{@member.display_name} gebucht"
  end
end
