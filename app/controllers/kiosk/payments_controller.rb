class Kiosk::PaymentsController < ApplicationController
  skip_before_action :authenticate_member!
  def show
    @member = current_organization.members.find(params[:id])
    amount = @member.balance_cents.abs

    girocode_data = [
      "BCD",
      "002",
      "1",
      "SCT",
      Setting.get("bank_bic", ""),
      Setting.get("bank_name", ""),
      Setting.get("bank_iban", ""),
      "EUR#{format("%.2f", amount / 100.0)}",
      "",
      "Rechnung #{@member.display_name}", # Verwendungszweck
      ""
    ].join("\n")

    @qr = RQRCode::QRCode.new(girocode_data)
    @amount = amount
  end
end
