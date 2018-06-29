# frozen_string_literal: true

class ApiController < ApplicationController
  # before_action -> { doorkeeper_authorize! :api }

  def wrap_in_bundle(results)
    # get just the FHIR resources, but then wrap it in an Entry.
    resources = results.map { |r| { resource: JSON.parse(r.resource) } }
    FHIR::Bundle.new(type: 'searchset', entry: resources)
  end
end
