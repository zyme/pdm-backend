# frozen_string_literal: true

class Encounter < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
