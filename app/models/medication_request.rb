# frozen_string_literal: true

class MedicationRequest < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
