# frozen_string_literal: true

class MedicationOrder < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
