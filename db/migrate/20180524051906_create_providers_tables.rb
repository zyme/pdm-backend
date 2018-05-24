Sequel.migration do
  change do
    create_table :providers do
      primary_key :id
      foreign_key :client_id, :clients, null: false
      foreign_key :parent_id, :providers
      column :name, String
      column :end_points, :jsonb
      column :created_at, DateTime
      column :updated_at, DateTime
    end

    create_table :user_providers do
      primary_key :id
      foreign_key :user_id, :users, null: false
      foreign_key :provider_id, :providers, null: false
      column :patient_id, String
      column :access_token, String
      column :refresh_token ,String
      column :last_sync , DateTime
      column :created_at, DateTime
      column :updated_at, DateTime
    end

  end
end
