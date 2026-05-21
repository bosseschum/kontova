class AddSuperAdminToMembers < ActiveRecord::Migration[8.1]
  def change
    add_column :members, :super_admin, :boolean
  end
end
