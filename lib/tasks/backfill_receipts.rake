namespace :requests do
  desc "Repoint existing Request receipt attachments from has_one (:receipt) to has_many (:receipts)"
  task backfill_receipts: :environment do
    attachments = ActiveStorage::Attachment.where(
      record_type: "Request",
      name: "receipt"
    )

    count = attachments.count
    puts "Found #{count} attachment(s) to repoint from 'receipt' to 'receipts'."

    if count.zero?
      puts "Nothing to do."
      next
    end

    ActiveRecord::Base.transaction do
      attachments.find_each do |attachment|
        attachment.update!(name: "receipts")
        puts "Repointed attachment ##{attachment.id} (Request ##{attachment.record_id})"
      end
    end

    puts "Done. Repointed #{count} attachment(s)."
  end
end
