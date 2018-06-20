# frozen_string_literal: true

class Goal < ApplicationRecord
  include CuratedModel
  belongs_to :profile

end
