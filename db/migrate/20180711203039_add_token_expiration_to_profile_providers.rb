# frozen_string_literal: true

class AddTokenExpirationToProfileProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :profile_providers, :expires_at, :int
  end
end
