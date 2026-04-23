class AddAdminToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :admin, :boolean
  end
end
