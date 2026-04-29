class MemberMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.member_mailer.invoice.subject
  #
  def invoice(member)
    @member = member
    @transactions = member.transactions.order(created_at: :desc).limit(50)
    @balance = member.balance

    mail(
      to: member.email,
      subject: "Hauptkasse des Tübinger Wingolfs - Kontoauszug #{Date.today.strftime("%B %Y")}"
    )
  end
end
