class AddAddressToProfiles < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :middle_name, :string
    add_column :profiles, :street, :string
    add_column :profiles, :city, :string
    add_column :profiles, :state, :string
    add_column :profiles, :zip, :string 
  end
end
