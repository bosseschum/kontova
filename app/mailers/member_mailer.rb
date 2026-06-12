class MemberMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.member_mailer.invoice.subject
  #

  def welcome(member, plain_pin, plain_password = nil, organization = nil)
    @member = member
    @pin = plain_pin
    @password = plain_password
    @organization = organization || member.organization_memberships.first&.organization

    mail(
      to: member.email,
      subject: "Willkommen bei #{@organization&.name || "Kontova"}!"
    )
  end

  def invoice(member, organization)
    @member = member
    @organization = organization
    @transactions = member.transactions.where(organization: organization)
      .order(created_at: :desc).limit(50)
    @balance = member.transactions.where(organization: organization)
      .not_sponsored.sum(:amount_cents) / 100.0

    mail(
      to: member.email,
      subject: "Hauptkasse des #{@organization&.name} - Kontoauszug #{Date.today.strftime("%B %Y")}"
    )
  end

  def request_approved(request, organization)
    @request = request
    @member = request.member
    @organization = organization

    mail(
      to: @member.email,
      subject: "#{@organization&.name} – Dein Antrag wurde genehmigt"
    )
  end

  def request_rejected(request, organization)
    @request = request
    @member = request.member
    @organization = organization

    mail(
      to: @member.email,
      subject: "#{@organization&.name} – Dein Antrag wurde abgelehnt"
    )
  end
end
