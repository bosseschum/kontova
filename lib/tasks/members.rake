namespace :members do
  desc "Halbjährlichen Mitgliedsbeitrag für alle Mitglieder buchen"
  task charge_fees: :environment do
    amount_cents = ENV.fetch("FEE_CENTS", 1000).to_i  # Standard: 10€

    Member.where(role: :member).each do |member|
      Transaction.create!(
        member:       member,
        amount_cents: -amount_cents,
        kind:         :membership_fee,
        note:         "Halbjährlicher Mitgliedsbeitrag #{Date.today.strftime("%m/%Y")}"
      )
      puts "Beitrag gebucht für #{member.display_name}"
    end

    puts "Fertig – #{Member.where(role: :member).count} Mitglieder belastet"
  end
end
