class MemberMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.member_mailer.invoice.subject
  #

  def welcome(member, plain_pin)
    @member = member
    @pin = plain_pin
    @password = plain_password
    @organization = member.organization

    mail(
      to: member.email,
      subject: "Willkommen bei #{@organization.name}!"
    )
  end

  def invoice(member)
    @member = member
    @transactions = member.transactions.order(created_at: :desc).limit(50)
    @balance = member.balance
    @organization = member.organization

    mail(
      to: member.email,
      subject: "Hauptkasse des #{@organization.name} - Kontoauszug #{Date.today.strftime("%B %Y")}"
    )
  end

  def request_approved(request)
    @request = request
    @member = request.member
    @organization = @member.organization

    mail(
      to: @member.email,
      subject: "#{@organization.name} – Dein Antrag wurde genehmigt"
    )
  end

  def request_rejected(request)
    @request = request
    @member = request.member
    @organization = @member.organization

    mail(
      to: @member.email,
      subject: "#{@organization.name} – Dein Antrag wurde abgelehnt"
    )
  end
end
