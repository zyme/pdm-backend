class CreateMedicationAdministrations < ActiveRecord::Migration[5.2]
  def change
    create_table :medication_administrations do |t|
      t.references :profile, null: false
      t.jsonb :resource, :jsonb
      t.string :version
      t.timestamps
    end
  end
end
