# frozen_string_literal: true

class Device < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
