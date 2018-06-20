# frozen_string_literal: true

class AllergyIntolerance < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
