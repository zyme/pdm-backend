Sequel.migration do
  change do
    create_table(:clients) do
      primary_key :id
      column :name, "text"
      column :type, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:oauth_applications) do
      primary_key :id
      column :name, "character varying(255)", :null=>false
      column :uid, "character varying(255)", :null=>false
      column :secret, "character varying(255)", :null=>false
      column :scopes, "character varying(255)", :default=>"", :null=>false
      column :redirect_uri, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      index [:uid], :unique=>true
    end
    
    create_table(:schema_migrations) do
      column :filename, "text", :null=>false
      
      primary_key [:filename]
    end
    
    create_table(:users) do
      primary_key :id
      column :first_name, "text", :default=>"", :null=>false
      column :last_name, "text", :default=>"", :null=>false
      column :email, "text", :default=>"", :null=>false
      column :encrypted_password, "text", :default=>"", :null=>false
      column :reset_password_token, "text"
      column :reset_password_sent_at, "text"
      column :remember_created_at, "timestamp without time zone"
      column :sign_in_count, "integer", :default=>0, :null=>false
      column :current_sign_in_at, "timestamp without time zone"
      column :last_sign_in_at, "timestamp without time zone"
      column :current_sign_in_ip, "text"
      column :last_sign_in_ip, "text"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
      
      index [:email], :unique=>true
      index [:reset_password_token], :unique=>true
    end
    
    create_table(:oauth_access_grants) do
      primary_key :id
      foreign_key :application_id, :oauth_applications, :null=>false, :key=>[:id], :on_delete=>:cascade
      column :resource_owner_id, "integer", :null=>false
      column :token, "character varying(255)", :null=>false
      column :expires_in, "integer", :null=>false
      column :redirect_uri, "text", :null=>false
      column :created_at, "timestamp without time zone", :null=>false
      column :revoked_at, "timestamp without time zone"
      column :scopes, "character varying(255)"
      
      index [:token], :unique=>true
    end
    
    create_table(:oauth_access_tokens) do
      primary_key :id
      foreign_key :application_id, :oauth_applications, :key=>[:id], :on_delete=>:cascade
      column :resource_owner_id, "integer"
      column :token, "character varying(255)", :null=>false
      column :refresh_token, "character varying(255)"
      column :previous_refresh_token, "character varying(255)", :default=>"", :null=>false
      column :expires_in, "integer"
      column :revoked_at, "timestamp without time zone"
      column :created_at, "timestamp without time zone", :null=>false
      column :scopes, "character varying(255)"
      
      index [:refresh_token], :unique=>true
      index [:resource_owner_id]
      index [:token], :unique=>true
    end
    
    create_table(:providers) do
      primary_key :id
      foreign_key :client_id, :clients, :null=>false, :key=>[:id]
      foreign_key :parent_id, :providers, :key=>[:id]
      column :name, "text"
      column :end_points, "jsonb"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:transactions) do
      primary_key :id
      foreign_key :user_id, :users, :key=>[:id]
      foreign_key :provider_id, :providers, :key=>[:id]
      column :type, "text"
      column :data, "jsonb"
      column :processed, "boolean"
      column :processed_time, "timestamp without time zone"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:user_providers) do
      primary_key :id
      foreign_key :user_id, :users, :null=>false, :key=>[:id]
      foreign_key :provider_id, :providers, :null=>false, :key=>[:id]
      column :patient_id, "text"
      column :access_token, "text"
      column :refresh_token, "text"
      column :last_sync, "timestamp without time zone"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:resources) do
      primary_key :id
      foreign_key :user_id, :users, :key=>[:id]
      foreign_key :provider_id, :providers, :key=>[:id]
      foreign_key :transaction_id, :transactions, :key=>[:id]
      column :resource_type, "text"
      column :provider_resource_id, "text"
      column :provider_resource_version, "text"
      column :fhir_version, "text"
      column :merged, "boolean"
      column :resource, "jsonb"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
    
    create_table(:operational_outcomes) do
      primary_key :id
      foreign_key :user_id, :users, :key=>[:id]
      foreign_key :resource_id, :resources, :key=>[:id]
      column :resolved, "boolean"
      column :type, "text"
      column :data, "jsonb"
    end
    
    create_table(:resource_histories) do
      primary_key :id
      foreign_key :resource_id, :resources, :key=>[:id]
      foreign_key :provider_id, :providers, :key=>[:id]
      foreign_key :transaction_id, :transactions, :key=>[:id]
      column :resource_type, "text"
      column :provider_resource_id, "text"
      column :provider_resource_version, "text"
      column :fhir_version, "text"
      column :merged, "boolean"
      column :resource, "jsonb"
      column :created_at, "timestamp without time zone"
      column :updated_at, "timestamp without time zone"
    end
  end
end
              Sequel.migration do
                change do
                  self << "SET search_path TO [\"mine\", \"public\"]"
                  self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524025638_devise_create_users.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524030931_create_doorkeeper_tables.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524050000_create_clients.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524051906_create_providers_tables.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524052000_create_transactions.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524052034_create_resources.rb')"
self << "INSERT INTO \"schema_migrations\" (\"filename\") VALUES ('20180524053910_create_operational_outcomes.rb')"
                end
              end
