# frozen_string_literal: true

class Resource < ApplicationRecord
  include FHIRWrapper

  belongs_to :data_receipt
  belongs_to :profile
  belongs_to :provider
end
