# frozen_string_literal: true

class AddRelationshipAndPhoneToProfile < ActiveRecord::Migration[5.2]
  def change
    add_column :profiles, :relationship, :string
    add_column :profiles, :telephone, :string
    add_column :profiles, :telephone_use, :string
  end
end
