# frozen_string_literal: true

class Provider < ApplicationRecord
  belongs_to :parent, foreign_key: :parent_id, class_name: 'Provider', optional: true
  has_one_attached :photo
  validates :name, :base_endpoint, presence: true

  def generate_auth_url(params = {})
    get_client.generate_auth_url(params)
  end

  def get_access_token(code, params = {})
    get_client.get_access_token(code, params)
  end

  delegate :subject_id_from_token, to: :get_client

  # This looks up the self provider. There should only be one, but if there are multiple, it
  # returns the one with the lowest ID. If none exist in the database, this returns nil.
  def self.find_self_provider
    Provider.where(provider_type: 'self').order(:id).first
  end

  private

  def get_client
    HDM::Client.get_client(self)
  end
end
