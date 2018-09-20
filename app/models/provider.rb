# frozen_string_literal: true

class Provider < ApplicationRecord
  belongs_to :parent, foreign_key: :parent_id, class_name: name, optional: true
  has_one_attached :photo
  validates :name, :base_endpoint, presence: true

  def generate_auth_url(params = {})
    get_client.generate_auth_url(params)
  end

  def get_access_token(code, params = {})
    get_client.get_access_token(code, params)
  end

  delegate :subject_id_from_token, to: :get_client

  private

  def get_client
    HDM::Client.get_client(self)
  end
end
