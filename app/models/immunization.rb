# frozen_string_literal: true

class Immunization < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
