# frozen_string_literal: true

class Coverage < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
