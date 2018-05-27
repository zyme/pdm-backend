class CreateProfiles< ActiveRecord::Migration[5.2]
  def change
    enable_extension "uuid-ossp"
    create_table :profiles do  |t|
      t.references :user, null: false
      t.uuid   :patient_id , default: -> { "uuid_generate_v4()" }, null: false
      t.string  :name, null: false
      t.string  :first_name
      t.string  :last_name
      t.string  :gender
      t.date  :dob
      t.timestamps
    end

  end
end
