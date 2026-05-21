class AddOrganizationToAll < ActiveRecord::Migration[8.1]
  def change
    add_reference :members, :organization, foreign_key: true
    add_reference :products, :organization, foreign_key: true
    add_reference :purchases, :organization, foreign_key: true
    add_reference :transactions, :organization, foreign_key: true
    add_reference :inventory_counts, :organization, foreign_key: true
    add_reference :settings, :organization, foreign_key: true
  end
end
