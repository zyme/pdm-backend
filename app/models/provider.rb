# frozen_string_literal: true

class Provider < ApplicationRecord
  belongs_to :parent, foreign_key: :parent_id, class_name: name

  validates :name, :base_endpoint, presence: true

  def generate_auth_url(params = {})
    get_client.generate_auth_url(params)
  end

  def get_access_token(code, params = {})
    get_client.get_access_token(code, params)
  end

  def subject_id_from_token(token)
    get_client.subject_id_from_token(token)
  end
  
  private

  def get_client
    HDM::Client.get_client(self)
  end
end
