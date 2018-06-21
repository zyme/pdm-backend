# frozen_string_literal: true

class ChangeTransactionToDataReceiptColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :resources, :transaction_id, :data_receipt_id
    rename_column :resource_histories, :transaction_id, :data_receipt_id
  end
end
