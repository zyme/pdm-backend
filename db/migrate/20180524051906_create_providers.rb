class CreateProviders< ActiveRecord::Migration[5.2]
  def change
    create_table :providers do |t|

      t.integer :parent_id, index: true
      t.string :provider_type , String, null: false
      t.string :name, String, null: false
      t.string :description, String, null: false, default: ""
      t.string :end_point, String
      t.timestamp
    end
    add_foreign_key :providers, :providers, column: :parent_id, primary_key: :id
  end
end
