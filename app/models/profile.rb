# frozen_string_literal: true

class Profile < ApplicationRecord
  belongs_to :user
  has_many :profile_providers
  has_many :providers, through: :profile_providers
  validates :name, presence: true

  def has_provider?(provider_id)
    return false if provider_id.nil?
    !providers.find_by(id: provider_id).nil?
  end
end
