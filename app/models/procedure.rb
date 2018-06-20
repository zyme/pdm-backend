# frozen_string_literal: true

class Procedure < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
