class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name, null: false
      t.string  :client_type , null: false
      t.timestamps
    end
  end
end
