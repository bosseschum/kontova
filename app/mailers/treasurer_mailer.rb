class TreasurerMailer < ApplicationMailer
  def new_request(request, organization)
    @request = request
    @member = request.member
    @organization = organization

    treasurer_emails = @organization.members
      .joins(:organization_memberships)
      .where(organization_memberships: { role: OrganizationMembership.roles[:treasurer] })
      .pluck(:email)

    mail(
      to: treasurer_emails,
      subject: "#{@organization.name} – Neuer Antrag von #{@member.display_name}",
    )
  end
end
