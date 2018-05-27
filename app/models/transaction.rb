class Transaction < ApplicationRecord

  belongs_to :provider
  belongs_to :user
  belongs_to :profile
  has_many :resources
end
