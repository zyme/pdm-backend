# frozen_string_literal: true

class MedicationStatement < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
