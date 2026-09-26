require "test_helper"

class KioskCheckoutTest < ActionDispatch::IntegrationTest
  setup do
    @organization = Organization.create!(
      name: "Testverein", subdomain: "testverein", active: true
    )
    @product = @organization.products.create!(
      name: "Bier", price_cents: 200, crate_size: 20, crate_price_cents: 1000
    )
    @membership = OrganizationMembership.create!(
      member: members(:one), organization: @organization, pin: "1234"
    )

    host! "testverein.example.com"
  end

  def add_to_cart(quantity, pin: "1234")
    post add_to_cart_kiosk_drinks_path,
      params: { product_id: @product.id, quantity: quantity, pin: pin }
  end

  test "successful checkout renders the success animation, books the cart and empties it" do
    add_to_cart 2

    assert_difference -> { Transaction.count }, 1 do
      post checkout_kiosk_drinks_path, params: { pin: "1234" }
    end
    assert_response :redirect

    transaction = Transaction.sole
    assert_equal members(:one), transaction.purchaser
    assert_equal @product, transaction.product
    assert_equal(-400, transaction.amount_cents)
    assert_equal 2, transaction.quantity

    follow_redirect!
    assert_response :success

    # The checkmark overlay that the user actually sees
    assert_select "#flash-notice", /Einkauf abgeschlossen/
    assert_select "#flash-notice .text-6xl", "✓"
    assert_select "#flash-alert", false
  end

  test "the cart is emptied after a successful checkout" do
    add_to_cart 2
    post checkout_kiosk_drinks_path, params: { pin: "1234" }
    follow_redirect!

    # A second checkout must not be able to book the same drinks again
    assert_no_difference -> { Transaction.count } do
      post checkout_kiosk_drinks_path, params: { pin: "1234" }
    end
    follow_redirect!

    assert_select "#flash-alert", /Warenkorb ist leer/
  end

  test "empty cart renders the error animation instead of the success animation" do
    post checkout_kiosk_drinks_path, params: { pin: "1234" }

    assert_response :redirect
    follow_redirect!

    assert_select "#flash-alert", /Warenkorb ist leer/
    assert_select "#flash-notice", false
    assert_select "script", /flash-alert/
  end

  test "unknown pin renders the error animation" do
    add_to_cart 1, pin: "9999"

    assert_no_difference -> { Transaction.count } do
      post checkout_kiosk_drinks_path, params: { pin: "9999" }
    end

    follow_redirect!
    assert_select "#flash-alert", /Unbekannte PIN/
  end

  test "balance limit renders the error animation" do
    # Push the member below the -100 EUR limit so the purchase is refused
    Transaction.create!(
      purchaser: members(:one), product: @product,
      amount_cents: -50_001, kind: :drink_purchase, quantity: 1
    )
    add_to_cart 1

    assert_no_difference -> { Transaction.count } do
      post checkout_kiosk_drinks_path, params: { pin: "1234" }
    end

    follow_redirect!
    assert_select "#flash-alert", /Saldo zu niedrig/
  end

  test "sponsored checkout books without touching the balance" do
    add_to_cart 3

    assert_difference -> { Transaction.count }, 1 do
      post checkout_kiosk_drinks_path, params: { pin: "1234", sponsored: "1" }
    end

    transaction = Transaction.sole
    assert_equal 0, transaction.amount_cents
    assert transaction.sponsored
    assert_equal members(:one).balance_cents, 0

    follow_redirect!
    assert_select "#flash-notice", /ohne Saldo-Abzug/
  end
end
