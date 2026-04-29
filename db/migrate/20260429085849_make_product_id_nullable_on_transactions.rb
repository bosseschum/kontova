class MakeProductIdNullableOnTransactions < ActiveRecord::Migration[8.1]
  def change
    change_column_null :transactions, :product_id, true
  end
end
