# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/member_mailer/invoice
  def invoice
    MemberMailer.invoice
  end
end
