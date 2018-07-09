# frozen_string_literal: true

class CreateAuditLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :audit_logs do |t|
      t.string :requester_info, null: false
      t.string :event, null: false
      t.datetime :event_time, null: false
      t.string :description, null: false
      t.timestamps
    end
  end
end
