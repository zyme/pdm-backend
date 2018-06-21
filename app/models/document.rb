# frozen_string_literal: true

class Document < ApplicationRecord
  include CuratedModel
  belongs_to :profile
end
