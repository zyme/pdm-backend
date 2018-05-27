class CreateProfileProviders < ActiveRecord::Migration[5.2]
  def change
    create_table :profile_providers do |t|

      t.references :profile, null: false
      t.references :provider, null: false
      t.string :patient_id , null: false
      t.string :access_token
      t.string :refresh_token
      t.timestamp :last_sync
      t.timestamp
    end

  end
end
