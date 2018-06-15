# frozen_string_literal: true

class AddScopesToProfileProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :profile_providers, :scopes, :string
  end
end
