# frozen_string_literal: true

class FhirUtilities
  attr_accessor :fhir, :fhir_string

  def initialize
    @fhir = FHIR::DSTU2 # or FHIR
    @fhir_string = 'FHIR::DSTU2' # or "FHIR"
  end
end
