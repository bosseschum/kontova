# Preview all emails at http://localhost:3000/rails/mailers/member_mailer
class MemberMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/member_mailer/welcome
  def welcome
    member = Member.first || Member.new(display_name: "Max Mustermann", email: "max@example.com")
    organization = member.organizations.first || Organization.first ||
      Organization.new(name: "Testverein e.V.", subdomain: "testverein")

    MemberMailer.welcome(member, "482913", "geheim123", organization)
  end

  # Preview this email at http://localhost:3000/rails/mailers/member_mailer/invoice
  def invoice
    organization = Organization.first
    member = organization&.members&.first
    return unless organization && member

    MemberMailer.invoice(member, organization)
  end
end
