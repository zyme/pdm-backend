Sequel.migration do
  change do
    create_table :transactions do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :provider_id, :providers
      column :type, String
      column :data , :jsonb
      column :processed , :boolean
      column :processed_time , DateTime
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end
end
