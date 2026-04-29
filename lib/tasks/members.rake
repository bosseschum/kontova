namespace :members do
  desc "Halbjährlichen Mitgliedsbeitrag für alle Mitglieder buchen"
  task charge_fees: :environment do
    Member.where(pays_fee: true).each do |member|
      Transaction.create!(
        member:       member,
        amount_cents: -member.fee_amount_cents,
        kind:         :membership_fee,
        note:         "Halbjährlicher Mitgliedsbeitrag #{Date.today.strftime("%m/%Y")}"
      )
      puts "#{member.display_name}: -#{member.fee_amount_cents / 100.0}€"
    end

    puts "Fertig – #{Member.where(role: :member).count} Mitglieder belastet"
  end

  desc "Kontoauszug per E-Mail versenden"
  task send_invoices: :environment do
    Member.all.each do |member|
      next if member.email.blank?
      MemberMailer.invoice(member).deliver_now
      puts "E-Mail gesendet an #{member.display_name} (#{member.email})"
    end
    puts "Fertig"
  end
end
