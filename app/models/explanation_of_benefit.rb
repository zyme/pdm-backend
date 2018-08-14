# frozen_string_literal: true

class ExplanationOfBenefit < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
