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
end
