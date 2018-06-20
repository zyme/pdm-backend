class CreateMedicationStatements < ActiveRecord::Migration[5.2]
  def change
    create_table :medication_statements do |t|
      t.references :profile, null: false
      t.jsonb :resource, :jsonb
      t.string :version
      t.timestamps
    end
  end
end
