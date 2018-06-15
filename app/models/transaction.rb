# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :provider
  belongs_to :profile
  has_many :resources
end
