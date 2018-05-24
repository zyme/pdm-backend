Sequel.migration do
  change do
    create_table :clients do
      primary_key :id
      column :name, String
      column :type , String 
      column :created_at, DateTime
      column :updated_at, DateTime
    end
  end
end
