class AddFeeAttributesToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :pays_fee, :boolean
    add_column :members, :lives_on_site, :boolean
  end
end
