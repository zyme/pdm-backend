class Resource < ApplicationRecord

  belongs_to :transaction
  belongs_to :user
  belongs_to :provider
end
