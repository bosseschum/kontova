class AddCrateSizeToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :crate_size, :integer
    add_column :products, :crate_price_cents, :integer
  end
end
