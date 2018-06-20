# frozen_string_literal: true

class Allergy < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
