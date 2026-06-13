class LandingMailer < ApplicationMailer
  def contact(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(
      to: "contact@kontova.de",
      reply_to: email,
      subject: "Kontova Kontaktanfrage von #{name}"
    )
  end
end
