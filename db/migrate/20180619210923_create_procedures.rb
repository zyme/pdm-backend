# frozen_string_literal: true

class CreateProcedures < ActiveRecord::Migration[5.2]
  def change
    create_table :procedures do |t|
      t.references :profile, null: false
      t.string :resource_id, null: false
      t.jsonb :resource, :jsonb
      t.string :version
      t.timestamps
    end
  end
end
