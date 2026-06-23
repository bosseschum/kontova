namespace :guests do
  desc "Rechnungen für abgelaufene Gast-Zugänge verschicken"
  task send_invoices: :environment do
    GuestAccess.expired_uninvoiced.find_each do |guest|
      next if guest.transactions.empty?
      GuestMailer.invoice(guest).deliver_now
      guest.update!(invoiced: true)
      puts "Rechnung an #{guest.email} gesendet (#{guest.total_spent_cents / 100.0}€)"
    end
  end
end
