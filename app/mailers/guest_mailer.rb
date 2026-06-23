class GuestMailer < ApplicationMailer
  def invoice(guest)
    @guest = guest
    @transactions = guest.transactions.order(created_at: :asc)
    @total = guest.total_spent_cents

    mail(to: guest.email, subject: "Deine Rechnung - #{guest.organization.name}")
  end
end
