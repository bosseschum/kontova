namespace :members do
  desc "Halbjährlichen Mitgliedsbeitrag für alle Organisationen buchen"
  task charge_fees: :environment do
    Organization.active.each do |org|
      members = org.members.where(pays_fee: true)

      members.each do |member|
        Transaction.create!(
          member:       member,
          amount_cents: -member.fee_amount_cents,
          kind:         :membership_fee,
          note:         "Halbjährlicher Mitgliedsbeitrag #{Date.today.strftime("%m/%Y")}"
        )
        puts "#{org.name} – #{member.display_name}: -#{member.fee_amount_cents / 100.0} €"
      end

      puts "#{org.name}: #{members.count} Mitglieder belastet"
    end

    puts "Fertig"
  end

  desc "Kontoauszug per E-Mail für alle Organisationen"
  task send_invoices: :environment do
    Organization.active.each do |org|
      org.members.each do |member|
        next if member.email.blank?
        MemberMailer.invoice(member).deliver_now
        puts "#{org.name} – E-Mail gesendet an #{member.display_name}"
      end
    end

    puts "Fertig"
  end
end
