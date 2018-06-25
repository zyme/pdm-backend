# frozen_string_literal: true

class Resource < ApplicationRecord
  belongs_to :data_receipt
  belongs_to :profile
  belongs_to :provider
end
