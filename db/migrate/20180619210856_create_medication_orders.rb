# frozen_string_literal: true

class CreateMedicationOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :medication_orders do |t|
      t.references :profile, null: false
      t.string :resource_id, null: false
      t.jsonb :resource
      t.string :version
      t.timestamps
    end
  end
end
