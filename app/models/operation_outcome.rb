# frozen_string_literal: true

class OperationOutcome < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
