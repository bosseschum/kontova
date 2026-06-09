class MakePurchasePriceOptional < ActiveRecord::Migration[8.1]
  def change
    change_column_null :purchases, :price_per_unit_cents, true
  end
end
