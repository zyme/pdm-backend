class CreateOperationalOutcomes < ActiveRecord::Migration[5.2]
  def change
    create_table :operational_outcomes do |t|

      t.references :profile
      t.references :resource
      t.boolean :resolved,  null: false, default: false
      t.string :oo_type
      t.jsonb :data
    end
  end
end
