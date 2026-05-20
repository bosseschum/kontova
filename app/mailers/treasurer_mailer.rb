class TreasurerMailer < ApplicationMailer
  def new_request(request)
    @request = request
    @member = request.member

    treasurer_emails = Member.where(role: :treasurer).pluck(:email)
    mail(
      to: treasurer_emails,
      subject: "Neuer Antrag von #{@member.display_name}",
    )
  end
end
