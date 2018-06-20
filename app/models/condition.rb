# frozen_string_literal: true

class Condition < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
