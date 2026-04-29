namespace :members do
  desc "Halbjährlichen Mitgliedsbeitrag für alle Mitglieder buchen"
  task charge_fees: :environment do
    amount_cents = ENV.fetch("FEE_CENTS", 1000).to_i  # Standard: 10€

    Member.where(pays_fee: true).each do |member|
      Transaction.create!(
        member:       member,
        amount_cents: -member.fee_amount_cents,
        kind:         :membership_fee,
        note:         "Halbjährlicher Mitgliedsbeitrag #{Date.today.strftime("%m/%Y")}"
      )
    end

    puts "Fertig – #{Member.where(role: :member).count} Mitglieder belastet"
  end
end
