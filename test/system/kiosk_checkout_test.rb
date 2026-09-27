require "application_system_test_case"

class KioskCheckoutSystemTest < ApplicationSystemTestCase
  PIN = "1234"
  HOST = "testverein.example.com"

  setup do
    @organization = Organization.create!(
      name: "Testverein", subdomain: "testverein", active: true
    )
    @product = @organization.products.create!(
      name: "Bier", price_cents: 200, crate_size: 20, crate_price_cents: 1000
    )
    OrganizationMembership.create!(
      member: members(:one), organization: @organization, pin: PIN
    )

    # Der Kiosk löst den Verein über die Subdomain auf, also muss der Browser
    # direkt auf dem Subdomain-Host landen (Port kommt von Capybara).
    Capybara.app_host = "http://#{HOST}"
    Capybara.always_include_port = true
  end

  teardown do
    Capybara.app_host = nil
    Capybara.always_include_port = false
  end

  def sign_in_and_add_to_cart
    visit "/kiosk"
    fill_in "pin", with: PIN
    click_on "Weiter"

    click_on "+ 1 Flasche"
    assert_text "1x Bier"
  end

  # Regression: der Submit-Button wurde im click-Handler synchron disabled.
  # Der Browser führt die Activation Behavior des Buttons erst danach aus und
  # bricht bei einem disabled Button ab, das Formular wurde also nie abgeschickt.
  test "clicking Bezahlen submits the form, books the cart and shows the success overlay" do
    sign_in_and_add_to_cart

    click_on "Bezahlen"

    # Capybara wartet hier auf die Navigation, die der Klick auslöst.
    assert_text "Einkauf abgeschlossen"

    transaction = Transaction.order(:created_at).last
    assert_equal members(:one), transaction.purchaser
    assert_equal @product, transaction.product
    assert_equal(-200, transaction.amount_cents)
    assert_equal 1, Transaction.count
  end
end
