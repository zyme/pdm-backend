class Provider < ApplicationRecord


  belongs_to :parent , foreign_key: :parent_id, class_name: self.name

  validates_presence_of :name, :base_endpoint


  def generate_auth_url(params={})
     get_client.generate_auth_url( params)
  end

  def get_access_token(code, params={})
    get_client.get_access_token(code,params)
  end

private

  def get_client
    HDM::Client.get_client(self)
  end



end
