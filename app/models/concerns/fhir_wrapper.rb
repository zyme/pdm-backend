# frozen_string_literal: true

module FHIRWrapper
  extend ActiveSupport::Concern

  def fhir_model
    @fhir_model ||= from_json
  end

  private

  def from_json
    if resource.instance_of? String
      FHIR.from_contents(resource)
    else
      resource_type = resource['resourceType']
      klass = Module.const_get("FHIR::#{resource_type}")
      klass.new(resource)
    end
  end
end
