# frozen_string_literal: true

class FhirUtilities
  attr_accessor :fhir, :fhir_string

  def initialize
    @fhir = FHIR # or FHIR::DSTU2 (note: tests fail when using FHIR::DSTU2 at present)
    @fhir_string = @fhir.name
  end
end
