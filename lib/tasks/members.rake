namespace :members do
  desc "Halbjährlichen Mitgliedsbeitrag für alle Organisationen buchen"
  task charge_fees: :environment do
    Organization.active.each do |org|
      memberships = org.organization_memberships.where(pays_fee: true)

      memberships.each do |membership|
        member = membership.member
        Transaction.create!(
          member:       member,
          organization: org,
          amount_cents: -membership.fee_amount_cents,
          kind:         :membership_fee,
          note:         "Halbjährlicher Mitgliedsbeitrag #{Date.today.strftime("%m/%Y")}"
        )
        puts "#{org.name} – #{member.display_name}: -#{membership.fee_amount_cents / 100.0} €"
      end

      puts "#{org.name}: #{memberships.count} Mitglieder belastet"
    end

    puts "Fertig"
  end

  desc "Kontoauszug per E-Mail für alle Organisationen"
  task send_invoices: :environment do
    Organization.active.each do |org|
      org.members.each do |member|
        next if member.email.blank?
        MemberMailer.invoice(member, org).deliver_now
        puts "#{org.name} – E-Mail gesendet an #{member.display_name}"
      end
    end

    puts "Fertig"
  end
end
