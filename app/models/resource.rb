# frozen_string_literal: true

class Resource < ApplicationRecord
  belongs_to :trans_action, class_name: 'Transaction'
  belongs_to :user
  belongs_to :provider
end
