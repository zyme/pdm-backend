# frozen_string_literal: true

class Claim < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
