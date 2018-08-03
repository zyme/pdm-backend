# frozen_string_literal: true

class ProviderApplication < ApplicationRecord
  belongs_to :provider
  belongs_to :application, class_name: 'Doorkeeper::Application'
end
