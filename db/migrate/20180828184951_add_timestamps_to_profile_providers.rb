class AddTimestampsToProfileProviders < ActiveRecord::Migration[5.2]
  def change
    add_column :profile_providers, :created_at, :timestamp
    add_column :profile_providers, :updated_at, :timestamp
  end
end
