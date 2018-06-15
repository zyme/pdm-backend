# frozen_string_literal: true

class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string :type, null: false
      t.string :base_endpoint
      t.string :token_endpoint
      t.string :authorization_endpoint
      t.string :default_scopes
      t.string :client_id
      t.string :client_secret
      t.timestamps
    end
  end
end
