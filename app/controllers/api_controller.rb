# frozen_string_literal: true

class ApiController < ApplicationController
  # before_action -> { doorkeeper_authorize! :api }

  def wrap_in_bundle(results)
    # get just the FHIR resources, but then wrap it in an Entry.
    resources = results.map { |r| wrap_in_entry(r.resource) }
    FHIR::Bundle.new(type: 'searchset', entry: resources)
  end

  def wrap_in_entry(obj)
    # FHIR::X.new() requires that these be hashes, not strings or full FHIR objects

    if obj.is_a? String
      obj = JSON.parse(obj)
    elsif obj.is_a? FHIR::Model
      obj = obj.to_hash
    end

    { resource: obj }
  end
end
