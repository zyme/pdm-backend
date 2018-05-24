Sequel.migration do
  change do
    create_table :resources do
      primary_key :id
      foreign_key :user_id , :users
      foreign_key :provider_id , :providers
      foreign_key :transaction_id, :transactions
      column :resource_type, String
      column :provider_resource_id, String
      column :provider_resource_version, String
      column :fhir_version , String
      column :merged , :boolean
      column :resource, :jsonb
      column :created_at, DateTime
      column :updated_at, DateTime
    end

    create_table :resource_histories do
      primary_key :id
      foreign_key :resource_id , :resources
      foreign_key :provider_id , :providers
      foreign_key :transaction_id, :transactions
      column :resource_type, String
      column :provider_resource_id, String
      column :provider_resource_version, String
      column :fhir_version , String
      column :merged , :boolean
      column :resource, :jsonb
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end
end
