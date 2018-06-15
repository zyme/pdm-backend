# frozen_string_literal: true

class CreateResources < ActiveRecord::Migration[5.2]
  def change
    create_table :resources do |t|
      t.references :user
      t.references :profile, null: false
      t.references :provider, null: false
      t.references :transaction, null: false
      t.string :resource_type, null: false
      t.string :provider_resource_id, null: false
      t.string :provider_resource_version, null: false
      t.string :data_specification_version, null: false, default: ''
      t.boolean :merged, :boolean, null: false, default: false
      t.jsonb :resource, :jsonb
      t.timestamps
    end

    create_table :resource_histories do |t|
      t.references :resource
      t.references :provider
      t.references :transaction
      t.string :resource_type
      t.string :provider_resource_id
      t.string :provider_resource_version
      t.string :fhir_version
      t.boolean :merged, :boolean
      t.jsonb :resource, :jsonb
      t.timestamps
    end
  end
end
