# frozen_string_literal: true

class CarePlan < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
