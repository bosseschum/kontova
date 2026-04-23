class AddPinToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :pin, :string
  end
end
