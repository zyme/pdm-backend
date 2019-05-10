class AddDigitalSignatureToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :dua_accepted_at, :datetime
    add_column :users, :dua_agreed_to, :boolean, null: false, default: false
    add_column :users, :dua_legal_name, :string
    add_column :users, :dua_remote_ip, :string
  end
end
