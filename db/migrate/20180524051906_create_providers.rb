# frozen_string_literal: true

class CreateProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|
      t.integer :parent_id, index: true
      t.string :provider_type, null: false
      t.string :name, null: false
      t.string :description, null: false, default: ''
      t.string :base_endpoint
      t.string :token_endpoint
      t.string :authorization_endpoint
      t.string :scopes
      t.string :client_id
      t.string :client_secret
      t.timestamp
    end
    add_foreign_key :providers, :providers, column: :parent_id, primary_key: :id
  end
end
