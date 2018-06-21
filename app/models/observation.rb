# frozen_string_literal: true

class Observation < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
