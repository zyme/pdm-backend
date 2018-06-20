# frozen_string_literal: true

class MedicationAdministration < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
