# frozen_string_literal: true

class RenameTransactionsToDataReceipts < ActiveRecord::Migration[5.2]
  def change
    rename_column :transactions, :transaction_type, :data_type
    rename_table :transactions, :data_receipts
  end
end
