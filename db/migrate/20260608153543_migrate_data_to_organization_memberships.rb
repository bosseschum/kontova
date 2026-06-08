class MigrateDataToOrganizationMemberships < ActiveRecord::Migration[8.1]
  def up
    Member.find_each do |member|
      next unless member.organization_id
      OrganizationMembership.create!(
        member: member,
        organization_id: member.organization_id,
        role: member.role,
        pin: member.pin,
        pays_fee: member.pays_fee,
        lives_on_site: member.lives_on_site
      )
    end
  end

  def down
    OrganizationMembership.find_each do |om|
      om.member.update_columns(
        organization_id: om.organization_id,
        role: om.role,
        pin: om.pin,
        pays_fee: om.pays_fee,
        lives_on_site: om.lives_on_site
      )
    end
  end
end
