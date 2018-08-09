# frozen_string_literal: true

class CreateProviderApplication < ActiveRecord::Migration[5.2]
  def change
    create_table :provider_applications do |t|
      t.references :provider, null: false
      t.references :application, null: false
      t.timestamps
    end
  end
end
