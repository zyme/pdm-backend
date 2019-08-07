# frozen_string_literal: true

module FHIRWrapper
  extend ActiveSupport::Concern

  def fhir_model
    @fhir_model ||= from_json
  end

  private

  def from_json
    fhir_manager = FhirUtilities.new
    fhir = fhir_manager.fhir
    fhir_str = fhir_manager.fhir_string
    if resource.instance_of? String
      fhir.from_contents(resource)
    else
      resource_type = resource['resourceType']
      klass = Module.const_get(fhir_str + "::#{resource_type}")
      klass.new(resource)
    end
  end
end
