class CreateTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table :transactions do |t|

      t.references :profile, null: false
      t.references :provider, null: false
      t.string :transaction_type, null: false
      t.jsonb :data , null: false
      t.boolean :processed
      t.timestamp :processed_time
      t.timestamps
    end
  end
end
