class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :subdomain
      t.boolean :active

      t.timestamps
    end
  end
end
