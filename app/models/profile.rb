class Profile < ApplicationRecord


  belongs_to :user
  has_many :profile_providers
  has_many :providers, through: :profile_providers
  validates_presence_of :name

  def has_provider?(provider_id)
    return false if provider_id.nil?
    !providers.find_by_id( provider_id).nil?
  end

end
