# frozen_string_literal: true

class CreateExplanationOfBenefits < ActiveRecord::Migration[5.2]
  def change
    create_table :explanation_of_benefits do |t|
      t.references :profile, null: false
      t.string :resource_id, null: false
      t.jsonb :resource
      t.string :version
      t.timestamps
    end
  end
end
