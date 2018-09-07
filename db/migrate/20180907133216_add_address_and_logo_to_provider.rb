# frozen_string_literal: true

class AddAddressAndLogoToProvider < ActiveRecord::Migration[5.2]
  def change
    add_column :providers, :street, :string
    add_column :providers, :city, :string
    add_column :providers, :state, :string
    add_column :providers, :zip, :string
    add_column :providers, :logo, :string
  end
end
