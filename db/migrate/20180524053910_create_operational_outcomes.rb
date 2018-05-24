Sequel.migration do
  change do
    create_table :operational_outcomes do
      primary_key :id
      foreign_key :user_id, :users
      foreign_key :resource_id , :resources
      column :resolved, :boolean
      column :type, String
      column :data , :jsonb
    end
  end
end
